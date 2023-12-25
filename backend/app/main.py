import firebase_admin
from app.router import router
from fastapi import FastAPI


app = FastAPI()
app.include_router(router)


def initialize_firebase():
    """Initializes firebase with correct credentials.

    No need to pass the credentials as we use the env variable
    GOOGLE_APPLICATION_CREDENTIALS. Note that this variable is
    set automatically on firebase Cloud run so no need to add service-account.json
    to the container. However, it means local docker containers will not work.
    """
    # cred = credentials.Certificate(creds_file_path)
    # firebase_admin.initialize_app(cred)
    firebase_admin.initialize_app()
