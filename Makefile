# where to install python venv: requirement files are in this directory
PROJECT_DIR=.
# frontend dir, where to install node_modules
FRONTEND_DIR=./frontend
# backend dir, where to create the .env file
BACKEND_DIR=./backend

.PHONY: help venv node_modules install check-prerequisites create-env-file check-service-account-file

# Display help message
help:
	@echo "Available targets:"
	@echo "  - help: Display this help message."
	@echo "  - check-prerequisites: checks that important libraries are installed"
	@echo "  - create-env-file: creates .env file from .env.example files"
	@echo "  - check-service-account-file: returns an error if service-account.json file is not present"
	@echo "  - venv: Create the python virtual environment and install dependencies"
	@echo "  - node_modules: Creates the node_modules directory and installs dependencies"
	@echo "  - install: checks that necessary tools and files are installed then launches venv and node_modules targets"
	@echo "  - clean: Remove generated files or directories."

# just here to make install fail if we don't have the right tools
check-prerequisites:
	@command -v python >/dev/null 2>&1 || { echo >&2 "Python is not installed. Aborting."; exit 1; }
	@command -v node >/dev/null 2>&1 || { echo >&2 "Node.js is not installed. Aborting."; exit 1; }
	@command -v ng >/dev/null 2>&1 || { echo >&2 "Angular CLI (ng) is not installed. Aborting."; exit 1; }

create-env-file:
	@test -e ${BACKEND_DIR}/.env || (echo "Creating ${BACKEND_DIR}/.env file, please update the fields" && cp ${BACKEND_DIR}/.env.example ${BACKEND_DIR}/.env )

check-service-account-file:
	@test -e ${BACKEND_DIR}/service-account.json || { echo >&2 "service-account.json file is not present. Generate a new private key from firebase console and save it as service-account.json"; exit 1; }

# inspired by https://stackoverflow.com/questions/24736146/how-to-use-virtualenv-in-makefile
# venv is a phony target: to know if we must update it we look at the touchfile
venv: ${PROJECT_DIR}/venv/touchfile

# checks for requirements and requirements-dev files, launches script if they were modified
# then we touch the touchfile so that its timestamp is more recent than the requirements files
${PROJECT_DIR}/venv/touchfile: ${PROJECT_DIR}/requirements.txt ${PROJECT_DIR}/requirements-dev.txt
	@echo "Setting up python virtual environment..."
	cd ${PROJECT_DIR} && \
		test -d venv || python -m venv venv
		. venv/bin/activate && \
		pip install --upgrade pip && \
		pip install -r ${PROJECT_DIR}/requirements.txt && \
		pip install -r ${PROJECT_DIR}/requirements-dev.txt && \
		pre-commit install
	touch ${PROJECT_DIR}/venv/touchfile



# same idea but for node_modules
node_modules: ${FRONTEND_DIR}/node_modules/touchfile

${FRONTEND_DIR}/node_modules/touchfile: ${FRONTEND_DIR}/package.json ${FRONTEND_DIR}/package-lock.json
	@echo "Setting up node_modules..."
	cd ${FRONTEND_DIR} && npm install
	touch ${FRONTEND_DIR}/node_modules/touchfile

install: check-prerequisites create-env-file  check-service-account-file venv node_modules
	@echo "Installation complete. Don't forget to activate environment"

clean:
	@echo "Cleaning up..."
	@echo "Removing python virtual environment..."
	rm -rf ${PROJECT_DIR}/venv
	@echo "Removing node_modules..."
	rm -rf ${FRONTEND_DIR}/node_modules

