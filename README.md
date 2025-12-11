# Sky Guide APNS backend

## Configuration for local development

To set up local testing, add the following to .env.local in the directory where sky-push has been cloned:

```
APP_ENV=local

# SQLite example
DATABASE_URL=sqlite://apns-backend.sqlite

APNS_KEY_PATH=/Users/claurel/.apns-keys/AuthKey_12345ABCD.p8
APNS_KEY_ID=12345ABCD
APNS_TEAM_ID=<Fifth Star Labs Team ID>
APNS_BUNDLE_ID=com.fifthstarlabs.skyguide
APNS_ENV=development
```

To load this file into the shell environment:

```
export $(cat .env.local | xargs)
```

### Steps

1. Resolve packages

```
swift package resolve
```


