.PHONY: run-local run-prod build-prod

run-local:
	flutter run --dart-define=API_BASE_URL=http://192.168.1.5:3000/api

run-prod:
	flutter run --dart-define=API_BASE_URL=http://52.172.248.68:3000/api

build-prod:
	flutter build apk --dart-define=API_BASE_URL=http://52.172.248.68:3000/api
