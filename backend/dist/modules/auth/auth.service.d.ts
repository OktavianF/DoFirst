export declare class AuthService {
    /**
     * Register a new user via Supabase Auth and create a profile in our DB.
     */
    signup(email: string, password: string, fullName: string): Promise<{
        user: {
            id: string;
            email: string | undefined;
        };
        profile: {
            id: string;
            fullName: string;
            avatarUrl: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
        session: {
            accessToken: string;
            refreshToken: string;
            expiresAt: number | undefined;
        } | null;
    }>;
    /**
     * Authenticate an existing user via Supabase Auth.
     */
    login(email: string, password: string): Promise<{
        user: {
            id: string;
            email: string | undefined;
        };
        profile: {
            id: string;
            fullName: string;
            avatarUrl: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
        session: {
            accessToken: string;
            refreshToken: string;
            expiresAt: number | undefined;
        };
    }>;
    /**
     * Retrieve the profile for a given user ID.
     */
    getProfile(userId: string): Promise<{
        id: string;
        fullName: string;
        avatarUrl: string | null;
        createdAt: Date;
        updatedAt: Date;
    }>;
    /**
     * Sign in with Google ID token.
     */
    googleSignIn(idToken: string): Promise<{
        user: {
            id: string;
            email: string | undefined;
        };
        profile: {
            id: string;
            fullName: string;
            avatarUrl: string | null;
            createdAt: Date;
            updatedAt: Date;
        };
        session: {
            accessToken: string;
            refreshToken: string;
            expiresAt: number | undefined;
        } | null;
    }>;
}
//# sourceMappingURL=auth.service.d.ts.map