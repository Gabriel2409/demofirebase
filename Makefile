VENV_PARENTDIR=.

.PHONY: help venv

# Display help message
help:
	@echo "Available targets:"
	@echo "  - help: Display this help message."
	@echo "  - venv: Create the virtual environment and install dependencies"

# inspired by https://stackoverflow.com/questions/24736146/how-to-use-virtualenv-in-makefile
venv: ${VENV_PARENTDIR}/venv/touchfile

# checks for requirements and requirements-dev files and
# launches script if they were modified
${VENV_PARENTDIR}/venv/touchfile: requirements.txt requirements-dev.txt
	cd ${VENV_PARENTDIR} && \
		test -d venv || python -m venv venv
		. venv/bin/activate && \
		pip install --upgrade pip && \
		pip install -r requirements.txt && \
		pip install -r requirements-dev.txt && \
		pre-commit install
	touch ${VENV_PARENTDIR}/venv/touchfile



# node_modules: ${NODE_MODULES_PARENTDIR}/node_modules/touchfile
#
# ${NODE_MODULES_PARENTDIR}/node_modules/touchfile: frontend/package.json frontend/package-lock.json
# 	cd frontend && npm install
# 	touch frontend/node_modules/touchfile
