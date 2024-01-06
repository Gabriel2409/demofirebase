# Firebase with angular and fastapi

Basic project to test firebase authentication with angular frontend and fastapi backend.

Medium article:

- https://medium.com/@gabriel.cournelle/firebase-authentication-in-angular-ab1b66d041dc

## Install the prerequisites

- python 3.10 or above, for ex with pyenv: https://github.com/pyenv/pyenv

- node v20.9.0 or above, for ex with nvm: https://github.com/nvm-sh/nvm

- angular cli: v17 or above: see https://angular.io/cli

- firebase admin for backend:
  - Go to your firebase console
  - Click on `Project Settings` then service accounts
  - Then click `Generate new private key`
  - Save it as `service-account.json` in the `backend` folder. Do not commit it!!

## Get all dependencies

- Run `make install` to create environments and install dependencies
- Don't forget to activate python environment afterwards: `source venv/bin/activate`

Note: look at the `Makefile` to see the details of the installation

## Post installation checks

- Installation should have created a `.env` file in the `backend` folder.
- Note that there is no sensitive information in this application so you won't need to modify it

## Running the application

- The simplest way is to use vscode task: `Run app` which will run the backend and the frontend
  You can check the details of the commands in `.vscode/tasks.json`
- Alternatively,

  - in `backend` folder, run `uvicorn app.main:app --reload`
  - in `frontend` folder: `ng serve`

- Check that frontend is running by going to `http://localhost:4200`
- Check that backend is running by going to `http://localhost:8000/docs`

## Using the application

- In the frontend, you can click on the links to go to a different route.
- First, click on `Signin page` and log in with your google account
- Then click on `Auth protected`, you should be able to access it (it will not work if you are not logged in)
- Then go back to `Landing page` and click `Get user id`. If you open the console, you should see your user id, which matches what is saved in firebase.
  You can also check the network tab to see that the request to the backend contains the authorization header with the bearer token.
