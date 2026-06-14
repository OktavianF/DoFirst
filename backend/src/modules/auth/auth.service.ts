import { supabaseAdmin } from '../../lib/supabase';
import { prisma } from '../../lib/prisma';
import { AppError } from '../../lib/AppError';
import { env } from '../../config/env';

export class AuthService {
  /**
   * Register a new user via Supabase Auth and create a profile in our DB.
   */
  async signup(email: string, password: string, fullName: string) {
    // Use admin API to create user (auto-confirms email)
    const { data: createData, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: { full_name: fullName },
    });

    if (createError) {
      throw AppError.badRequest(createError.message);
    }

    if (!createData.user) {
      throw AppError.badRequest('Signup failed');
    }

    // Create profile in our database
    const profile = await prisma.profile.create({
      data: {
        id: createData.user.id,
        fullName,
      },
    });

    // Sign in immediately to get session tokens
    const { data: loginData, error: loginError } = await supabaseAdmin.auth.signInWithPassword({
      email,
      password,
    });

    return {
      user: {
        id: createData.user.id,
        email: createData.user.email,
      },
      profile,
      session: loginError ? null : {
        accessToken: loginData.session.access_token,
        refreshToken: loginData.session.refresh_token,
        expiresAt: loginData.session.expires_at,
      },
    };
  }

  /**
   * Authenticate an existing user via Supabase Auth.
   */
  async login(email: string, password: string) {
    const { data, error } = await supabaseAdmin.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      throw AppError.unauthorized(error.message);
    }

    // Ensure profile exists (self-healing)
    let profile = await prisma.profile.findUnique({
      where: { id: data.user.id },
    });

    if (!profile) {
      profile = await prisma.profile.create({
        data: {
          id: data.user.id,
          fullName: data.user.user_metadata?.full_name || 'User',
        },
      });
    }

    return {
      user: {
        id: data.user.id,
        email: data.user.email,
      },
      profile,
      session: {
        accessToken: data.session.access_token,
        refreshToken: data.session.refresh_token,
        expiresAt: data.session.expires_at,
      },
    };
  }

  /**
   * Retrieve the profile for a given user ID.
   */
  async getProfile(userId: string) {
    const profile = await prisma.profile.findUnique({
      where: { id: userId },
    });

    if (!profile) {
      throw AppError.notFound('Profile not found');
    }

    return profile;
  }

  /**
   * Refresh an expired session using a refresh token.
   * Returns new access + refresh tokens.
   */
  async refreshSession(refreshToken: string) {
    const { data, error } = await supabaseAdmin.auth.refreshSession({
      refresh_token: refreshToken,
    });

    if (error || !data.session) {
      throw AppError.unauthorized('Session expired. Please log in again.');
    }

    return {
      session: {
        accessToken: data.session.access_token,
        refreshToken: data.session.refresh_token,
        expiresAt: data.session.expires_at,
      },
    };
  }

  /**
   * Send a password reset email via Supabase Auth.
   * Only allows @gmail.com emails so the reset link is delivered to Gmail.
   */
  async forgotPassword(email: string) {
    // Validate Gmail domain
    const normalizedEmail = email.trim().toLowerCase();
    if (!normalizedEmail.endsWith('@gmail.com')) {
      throw AppError.badRequest(
        'Password reset is only available for Gmail accounts. Please use your @gmail.com email.'
      );
    }

    const redirectTo = `${env.APP_URL}/auth/reset-password`;
    const { error } = await supabaseAdmin.auth.resetPasswordForEmail(normalizedEmail, {
      redirectTo,
    });

    if (error) {
      throw AppError.badRequest(error.message);
    }

    return { message: 'Password reset link sent to your Gmail' };
  }

  /**
   * Sign in with Google ID token.
   */
  async googleSignIn(idToken: string) {
    const { data, error } = await supabaseAdmin.auth.signInWithIdToken({
      provider: 'google',
      token: idToken,
    });

    if (error) {
      throw AppError.unauthorized(error.message);
    }

    // Ensure profile exists (self-healing)
    let profile = await prisma.profile.findUnique({
      where: { id: data.user.id },
    });

    if (!profile) {
      profile = await prisma.profile.create({
        data: {
          id: data.user.id,
          fullName: data.user.user_metadata?.full_name || data.user.user_metadata?.name || 'User',
          avatarUrl: data.user.user_metadata?.avatar_url || null,
        },
      });
    }

    return {
      user: {
        id: data.user.id,
        email: data.user.email,
      },
      profile,
      session: data.session ? {
        accessToken: data.session.access_token,
        refreshToken: data.session.refresh_token,
        expiresAt: data.session.expires_at,
      } : null,
    };
  }

  /**
   * Reset a user's password using the access token from the password recovery redirect.
   * Uses Admin API for reliability (avoids PKCE/crypto issues on non-HTTPS).
   */
  async resetPassword(password: string, accessToken: string) {
    // Verify the access token to extract the user identity
    const { data: userData, error: verifyError } = await supabaseAdmin.auth.getUser(accessToken);

    if (verifyError || !userData.user) {
      throw AppError.badRequest('Invalid or expired reset token. Please request a new password reset link.');
    }

    // Use admin API to update the password (bypasses client-side crypto requirements)
    const { error } = await supabaseAdmin.auth.admin.updateUserById(userData.user.id, {
      password,
    });

    if (error) {
      throw AppError.badRequest(error.message);
    }

    return { success: true, message: 'Password updated successfully' };
  }
}

