ifneq (,)
.error This Makefile requires GNU Make.
endif

# Ensure additional Makefiles are present
MAKEFILES = Makefile.docker Makefile.lint
$(MAKEFILES): URL=https://raw.githubusercontent.com/devilbox/makefiles/master/$(@)
$(MAKEFILES):
	@if ! (curl --fail -sS -o $(@) $(URL) || wget -O $(@) $(URL)); then \
		echo "Error, curl or wget required."; \
		echo "Exiting."; \
		false; \
	fi
include $(MAKEFILES)

# Set default Target
.DEFAULT_GOAL := help


# -------------------------------------------------------------------------------------------------
# Default configuration
# -------------------------------------------------------------------------------------------------
# Own vars
TAG        = latest

# Makefile.docker overwrites
NAME       = ansible
VERSION    = latest
IMAGE      = cytopia/ansible
FLAVOUR    = default
STAGE      = builder
DIR        = Dockerfiles
DOCKER_TAG = $(VERSION)

# Never pull this image if mentioned in FROM tag
DOCKER_PULL_BASE_IMAGES_IGNORE = cytopia/ansible-builder

# Determine Dockerfile to use
ifeq ($(strip $(STAGE)),builder)
	FILE = builder
	IMAGE = cytopia/ansible-builder
	DOCKER_TAG = latest
endif
ifeq ($(strip $(STAGE)),base)
	FILE = Dockerfile
endif
ifeq ($(strip $(STAGE)),tools)
	FILE = Dockerfile-tools
	DOCKER_TAG = $(VERSION)-tools
endif
ifeq ($(strip $(STAGE)),infra)
	FILE = Dockerfile-infra
	DOCKER_TAG = $(VERSION)-infra
endif
ifeq ($(strip $(STAGE)),azure)
	FILE = Dockerfile-azure
	DOCKER_TAG = $(VERSION)-azure
endif
ifeq ($(strip $(STAGE)),aws)
	FILE = Dockerfile-aws
	DOCKER_TAG = $(VERSION)-aws
endif
ifeq ($(strip $(STAGE)),awsk8s)
	FILE = Dockerfile-awsk8s
	DOCKER_TAG = $(VERSION)-awsk8s
endif
ifeq ($(strip $(STAGE)),awskops)
	FILE = Dockerfile-awskops
	DOCKER_TAG = $(VERSION)-awskops
endif
ifeq ($(strip $(STAGE)),awshelm)
	FILE = Dockerfile-awshelm
	DOCKER_TAG = $(VERSION)-awshelm
endif

## Building from master branch: Tag == 'latest'
#ifeq ($(strip $(TAG)),latest)
#	ifeq ($(strip $(VERSION)),latest)
#		DOCKER_TAG = $(FLAVOUR)
#	else
#		ifeq ($(strip $(FLAVOUR)),latest)
#			ifeq ($(strip $(PHP_VERSION)),latest)
#				DOCKER_TAG = $(PCS_VERSION)
#			else
#				DOCKER_TAG = $(PCS_VERSION)-php$(PHP_VERSION)
#			endif
#		else
#			ifeq ($(strip $(PHP_VERSION)),latest)
#				DOCKER_TAG = $(FLAVOUR)-$(PCS_VERSION)
#			else
#				DOCKER_TAG = $(FLAVOUR)-$(PCS_VERSION)-php$(PHP_VERSION)
#			endif
#		endif
#	endif
## Building from any other branch or tag: Tag == '<REF>'
#else
#	ifeq ($(strip $(VERSION)),latest)
#		ifeq ($(strip $(FLAVOUR)),latest)
#			DOCKER_TAG = latest-$(TAG)
#		else
#			DOCKER_TAG = $(FLAVOUR)-latest-$(TAG)
#		endif
#	else
#		ifeq ($(strip $(FLAVOUR)),latest)
#			ifeq ($(strip $(PHP_VERSION)),latest)
#				DOCKER_TAG = $(PCS_VERSION)-$(TAG)
#			else
#				DOCKER_TAG = $(PCS_VERSION)-php$(PHP_VERSION)-$(TAG)
#			endif
#		else
#			ifeq ($(strip $(PHP_VERSION)),latest)
#				DOCKER_TAG = $(FLAVOUR)-$(PCS_VERSION)-$(TAG)
#			else
#				DOCKER_TAG = $(FLAVOUR)-$(PCS_VERSION)-php$(PHP_VERSION)-$(TAG)
#			endif
#		endif
#	endif
#endif

# Makefile.lint overwrites
FL_IGNORES  = .git/,.github/,tests/
SC_IGNORES  = .git/,.github/,tests/
JL_IGNORES  = .git/,.github/,./tests/


# -------------------------------------------------------------------------------------------------
#  Default Target
# -------------------------------------------------------------------------------------------------
.PHONY: help
help:
	@echo "lint                                     Lint project files and repository"
	@echo
	@echo "build [ARCH=...] [TAG=...]               Build Docker image"
	@echo "rebuild [ARCH=...] [TAG=...]             Build Docker image without cache"
	@echo "push [ARCH=...] [TAG=...]                Push Docker image to Docker hub"
	@echo
	@echo "manifest-create [ARCHES=...] [TAG=...]   Create multi-arch manifest"
	@echo "manifest-push [TAG=...]                  Push multi-arch manifest"
	@echo
	@echo "test [ARCH=...]                          Test built Docker image"
	@echo


# -------------------------------------------------------------------------------------------------
#  Docker Targets
# -------------------------------------------------------------------------------------------------
.PHONY: build
build: ARGS+=--build-arg VERSION=$(VERSION)
build: ARGS+=--build-arg KOPS=$(KOPS)
build: ARGS+=--build-arg HELM=$(HELM)
build: docker-arch-build

.PHONY: rebuild
rebuild: ARGS+=--build-arg VERSION=$(VERSION)
rebuild: ARGS+=--build-arg KOPS=$(KOPS)
rebuild: ARGS+=--build-arg HELM=$(HELM)
rebuild: docker-arch-rebuild

.PHONY: push
push: docker-arch-push


# -------------------------------------------------------------------------------------------------
#  Manifest Targets
# -------------------------------------------------------------------------------------------------
.PHONY: manifest-create
manifest-create: docker-manifest-create

.PHONY: manifest-push
manifest-push: docker-manifest-push


# -------------------------------------------------------------------------------------------------
#  Save / Load Targets
# -------------------------------------------------------------------------------------------------
.PHONY: save
save: docker-save

.PHONY: load
load: docker-load

.PHONY: save-verify
save-verify: save
save-verify: load


# -------------------------------------------------------------------------------------------------
#  Target Overrides
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
#  Test Targets
# -------------------------------------------------------------------------------------------------












#ifneq (,)
#.error This Makefile requires GNU Make.
#endif
#
## -------------------------------------------------------------------------------------------------
## Default configuration
## -------------------------------------------------------------------------------------------------
#.PHONY: lint build rebuild test tag pull-base-image login push enter
#
#CURRENT_DIR = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
#
## -------------------------------------------------------------------------------------------------
## File-lint configuration
## -------------------------------------------------------------------------------------------------
#FL_VERSION = 0.4
#FL_IGNORES = .git/,.github/,tests/
#
## -------------------------------------------------------------------------------------------------
## Docker configuration
## -------------------------------------------------------------------------------------------------
#DIR = Dockerfiles/
#FILE = Dockerfile
#IMAGE = cytopia/ansible
#TAG = latest
#NO_CACHE =
#
## Version & Flavour
#ANSIBLE = latest
#FLAVOUR = base
#KOPS =
#HELM =


# -------------------------------------------------------------------------------------------------
# Default Target
# -------------------------------------------------------------------------------------------------
#help:
#	@echo "--------------------------------------------------------------------------------"
#	@echo " Build Targets"
#	@echo "--------------------------------------------------------------------------------"
#	@echo
#	@echo "All Docker images are build as follows: $(IMAGE):\$$ANSIBLE[-\$$FLAVOUR[\$$KOPS|\$$HELM]]"
#	@echo
#	@echo "build   [ANSIBLE=] [KOPS=] [HELM=]        Build Docker image"
#	@echo "rebuild [ANSIBLE=] [KOPS=] [HELM=]        Build Docker image without cache"
#	@echo
#	@echo "    make build ANSIBLE=2.3"
#	@echo "    make build ANSIBLE=2.3 FLAVOUR=tools"
#	@echo "    make build ANSIBLE=2.3 FLAVOUR=infra"
#	@echo "    make build ANSIBLE=2.3 FLAVOUR=azure"
#	@echo "    make build ANSIBLE=2.3 FLAVOUR=aws"
#	@echo "    make build ANSIBLE=2.3 FLAVOUR=awsk8s"
#	@echo "    make build ANSIBLE=2.3 FLAVOUR=awshelm HELM=2.11"
#	@echo "    make build ANSIBLE=2.3 FLAVOUR=awskops KOPS=1.15"
#	@echo
#	@echo "--------------------------------------------------------------------------------"
#	@echo " Test Targets"
#	@echo "--------------------------------------------------------------------------------"
#	@echo
#	@echo "test [ANSIBLE=] [KOPS=] [HELM=]           Test built Docker image"
#	@echo
#	@echo "    make test ANSIBLE=2.3"
#	@echo "    make test ANSIBLE=2.3 FLAVOUR=tools"
#	@echo "    make test ANSIBLE=2.3 FLAVOUR=infra"
#	@echo "    make test ANSIBLE=2.3 FLAVOUR=azure"
#	@echo "    make test ANSIBLE=2.3 FLAVOUR=aws"
#	@echo "    make test ANSIBLE=2.3 FLAVOUR=awsk8s"
#	@echo "    make test ANSIBLE=2.3 FLAVOUR=awshelm HELM=2.11"
#	@echo "    make test ANSIBLE=2.3 FLAVOUR=awskops KOPS=1.15"
#	@echo
#	@echo "--------------------------------------------------------------------------------"
#	@echo " Tagging Target"
#	@echo "--------------------------------------------------------------------------------"
#	@echo
#	@echo "tag [ANSIBLE=] [KOPS=] [HELM=] [TAG=]     Tag built Docker image"
#	@echo
#	@echo "    make tag ANSIBLE=2.3 TAG=2.3-mysuffix"
#	@echo "    make tag ANSIBLE=2.3 FLAVOUR=tools TAG=2.3-tools-mysuffix"
#	@echo "    make tag ANSIBLE=2.3 FLAVOUR=infra TAG=2.3-infra-mysuffix"
#	@echo "    make tag ANSIBLE=2.3 FLAVOUR=azure TAG=2.3-azure-mysuffix"
#	@echo "    make tag ANSIBLE=2.3 FLAVOUR=aws TAG=2.3-aws-mysuffix"
#	@echo "    make tag ANSIBLE=2.3 FLAVOUR=awsk8s TAG=2.3-awsk8s-mysuffix"
#	@echo "    make tag ANSIBLE=2.3 FLAVOUR=awshelm HELM=2.11 TAG=2.3-awshelm-mysuffix"
#	@echo "    make tag ANSIBLE=2.3 FLAVOUR=awskops KOPS=1.15 TAG=2.3-awskops-mysuffix"
#	@echo
#	@echo "--------------------------------------------------------------------------------"
#	@echo " MISC Targets"
#	@echo "--------------------------------------------------------------------------------"
#	@echo
#	@echo "lint                                      Lint repository"
#	@echo "pull-base-image                           Pull the base Docker image"
#	@echo "login [USERNAME=] [PASSWORD=]             Login to Dockerhub"
#	@echo "push  [TAG=]                              Push Docker image to Dockerhub"
#	@echo "enter [TAG=]                              Run and enter Docker built image"



# -------------------------------------------------------------------------------------------------
# Build Targets
# -------------------------------------------------------------------------------------------------

#_build_builder:
#	docker build $(NO_CACHE) --build-arg VERSION=$(ANSIBLE) \
#		-t cytopia/ansible-builder -f ${DIR}/builder ${DIR}
#
#build: _build_builder
#build:
#	@ \
#	if [ "$(FLAVOUR)" = "base" ]; then \
#		docker build \
#			$(NO_CACHE) \
#			--label "org.opencontainers.image.created"="$$(date --rfc-3339=s)" \
#			--label "org.opencontainers.image.revision"="$$(git rev-parse HEAD)" \
#			--label "org.opencontainers.image.version"="${VERSION}" \
#			--build-arg VERSION=$(ANSIBLE) \
#			-t $(IMAGE):$(ANSIBLE) -f $(DIR)/$(FILE) $(DIR); \
#	elif [ "$(FLAVOUR)" = "awshelm" ]; then \
#		if [ -z "$(HELM)" ]; then \
#			echo "Error, HELM variable required."; \
#			exit 1; \
#		fi; \
#		docker build \
#			$(NO_CACHE) \
#			--label "org.opencontainers.image.created"="$$(date --rfc-3339=s)" \
#			--label "org.opencontainers.image.revision"="$$(git rev-parse HEAD)" \
#			--label "org.opencontainers.image.version"="${VERSION}" \
#			--build-arg VERSION=$(ANSIBLE) \
#			--build-arg HELM=$(HELM) \
#			-t $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(HELM) -f $(DIR)/$(FILE)-$(FLAVOUR) $(DIR); \
#	elif [ "$(FLAVOUR)" = "awskops" ]; then \
#		if [ -z "$(KOPS)" ]; then \
#			echo "Error, KOPS variable required."; \
#			exit 1; \
#		fi; \
#		docker build \
#			$(NO_CACHE) \
#			--label "org.opencontainers.image.created"="$$(date --rfc-3339=s)" \
#			--label "org.opencontainers.image.revision"="$$(git rev-parse HEAD)" \
#			--label "org.opencontainers.image.version"="${VERSION}" \
#			--build-arg VERSION=$(ANSIBLE) \
#			--build-arg KOPS=$(KOPS) \
#			-t $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(KOPS) -f $(DIR)/$(FILE)-$(FLAVOUR) $(DIR); \
#	else \
#		docker build \
#			$(NO_CACHE) \
#			--label "org.opencontainers.image.created"="$$(date --rfc-3339=s)" \
#			--label "org.opencontainers.image.revision"="$$(git rev-parse HEAD)" \
#			--label "org.opencontainers.image.version"="${VERSION}" \
#			--build-arg VERSION=$(ANSIBLE) \
#			-t $(IMAGE):$(ANSIBLE)-$(FLAVOUR) -f $(DIR)/$(FILE)-$(FLAVOUR) $(DIR); \
#	fi
#
#rebuild: NO_CACHE=--no-cache
#rebuild: pull-base-image
#rebuild: build


# -------------------------------------------------------------------------------------------------
# Test Targets
# -------------------------------------------------------------------------------------------------
test: test-ansible-version
test: test-python-libs
test: test-binaries
test: test-helm-version
test: test-kops-version
test: test-run-user-root
test: test-run-user-ansible

.PHONY: test-ansible-version
test-ansible-version:
	@echo "################################################################################"
	@echo "# Testing correct Ansible version"
	@echo "################################################################################"
	@\
	if echo '$(ANSIBLE)' | grep -Eq 'latest\-?'; then \
		echo "Fetching latest version from GitHub"; \
		TEST_VERSION="$$( \
			curl -L -sS  https://github.com/ansible/ansible/releases/ \
				| tac | tac \
				| grep -Eo "ansible/ansible/releases/tag/v[.0-9]+\"" \
				| sed 's/.*v//g' \
				| sed 's/\"//g' \
				| sort -V \
				| tail -1 \
		)"; \
	else \
		TEST_VERSION="$$( echo '$(ANSIBLE)' )"; \
	fi; \
	\
	\
	echo "Testing against Ansible version: $${TEST_VERSION}"; \
	\
	\
	if [ "$(FLAVOUR)" = "base" ]; then \
		if ! docker run --rm $(IMAGE):$(ANSIBLE) ansible --version | grep -E "^[Aa]nsible.+$${TEST_VERSION}"; then \
			echo "[FAILED]"; \
			docker run --rm $(IMAGE):$(ANSIBLE) ansible --version; \
			exit 1; \
		fi; \
	else \
		if ! docker run --rm $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(HELM)$(KOPS) ansible --version | grep -E "^[Aa]nsible.+$${TEST_VERSION}"; then \
			echo "[FAILED]"; \
			docker run --rm $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(HELM)$(KOPS) ansible --version; \
			exit 1; \
		fi; \
	fi; \
	echo "[SUCCESS]"; \
	echo

.PHONY: test-python-libs
test-python-libs:
	@echo "################################################################################"
	@echo "# Testing correct Python libraries"
	@echo "################################################################################"
	@\
	\
	\
	if [ "$(FLAVOUR)" = "base" ]; then \
		LIBS="$$( docker run --rm $(IMAGE):$(ANSIBLE) pip3 freeze )"; \
	else \
		LIBS="$$( docker run --rm $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(HELM)$(KOPS) pip3 freeze )"; \
	fi; \
	\
	\
	REQUIRED_BASE="cffi cryptography paramiko Jinja2 PyYAML"; \
	REQUIRED_TOOLS="dnspython mitogen"; \
	REQUIRED_INFRA="docker docker-compose jsondiff pexpect psycopg2 pypsexec pymongo PyMySQL smbprotocol"; \
	REQUIRED_AZURE="azure\-.*"; \
	REQUIRED_AWS="awscli botocore boto boto3"; \
	REQUIRED_AWSK8S="openshift"; \
	REQUIRED_AWSKOPS=""; \
	REQUIRED_AWSHELM=""; \
	\
	\
	if [ "$(FLAVOUR)" = "base" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
		for lib in $${REQUIRED_TOOLS}; do \
			if ! echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] unwanted lib not available: $${lib}"; \
			else \
				echo "[FAILED] unwanted lib available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "tools" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
		for lib in $${REQUIRED_INFRA}; do \
			if ! echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] unwanted lib not available: $${lib}"; \
			else \
				echo "[FAILED] unwanted lib available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "infra" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_INFRA} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
		for lib in $${REQUIRED_AZURE}; do \
			if ! echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] unwanted lib not available: $${lib}"; \
			else \
				echo "[FAILED] unwanted lib available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "azure" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AZURE} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
		for lib in $${REQUIRED_AWS}; do \
			if ! echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] unwanted lib not available: $${lib}"; \
			else \
				echo "[FAILED] unwanted lib available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "aws" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
		for lib in $${REQUIRED_AWSK8S}; do \
			if ! echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] unwanted lib not available: $${lib}"; \
			else \
				echo "[FAILED] unwanted lib available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "awsk8s" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} $${REQUIRED_AWSK8S} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
		for lib in $$( echo $${REQUIRED_AWSKOPS} $${REQUIRED_AWSHELM} ); do \
			if ! echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] unwanted lib not available: $${lib}"; \
			else \
				echo "[FAILED] unwanted lib available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "awskops" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} $${REQUIRED_AWSK8S} $${REQUIRED_AWSKOPS} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "awshelm" ]; then \
		for lib in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} $${REQUIRED_AWSK8S} $${REQUIRED_AWSHELM} ); do \
			if echo "$${LIBS}" | grep -E "^$${lib}" >/dev/null; then \
				echo "[OK] required lib available: $${lib}"; \
			else \
				echo "[FAILED] required lib not available: $${lib}"; \
				exit 1; \
			fi; \
		done; \
	\
	fi; \
	echo "[SUCCESS]"; \
	echo

.PHONY: test-binaries
test-binaries:
	@echo "################################################################################"
	@echo "# Testing correct Binaries"
	@echo "################################################################################"
	@\
	\
	\
	if [ "$(FLAVOUR)" = "base" ]; then \
		BINS="$$( docker run --rm $(IMAGE):$(ANSIBLE) find /usr/bin/ -type f | sed 's|/usr/bin/||g' )"; \
	else \
		BINS="$$( docker run --rm $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(HELM)$(KOPS) find /usr/bin/ -type f | sed 's|/usr/bin/||g' )"; \
	fi; \
	\
	\
	REQUIRED_BASE="python"; \
	REQUIRED_TOOLS="git gpg jq yq ssh"; \
	REQUIRED_INFRA="rsync"; \
	REQUIRED_AZURE=""; \
	REQUIRED_AWS="aws aws-iam-authenticator"; \
	REQUIRED_AWSK8S="kubectl oc"; \
	REQUIRED_AWSKOPS="kops"; \
	REQUIRED_AWSHELM="helm"; \
	\
	\
	if [ "$(FLAVOUR)" = "base" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
		for bin in $${REQUIRED_TOOLS}; do \
			if ! echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] unwanted bin not available: $${bin}"; \
			else \
				echo "[FAILED] unwanted bin available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "tools" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
		for bin in $${REQUIRED_INFRA}; do \
			if ! echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] unwanted bin not available: $${bin}"; \
			else \
				echo "[FAILED] unwanted bin available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "infra" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_INFRA} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
		for bin in $${REQUIRED_AZURE}; do \
			if ! echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] unwanted bin not available: $${bin}"; \
			else \
				echo "[FAILED] unwanted bin available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "azure" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AZURE} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
		for bin in $${REQUIRED_AWS}; do \
			if ! echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] unwanted bin not available: $${bin}"; \
			else \
				echo "[FAILED] unwanted bin available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "aws" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
		for bin in $${REQUIRED_AWSK8S}; do \
			if ! echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] unwanted bin not available: $${bin}"; \
			else \
				echo "[FAILED] unwanted bin available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "awsk8s" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} $${REQUIRED_AWSK8S} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
		for bin in $$( echo $${REQUIRED_AWSKOPS} $${REQUIRED_AWSHELM} ); do \
			if ! echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] unwanted bin not available: $${bin}"; \
			else \
				echo "[FAILED] unwanted bin available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "awskops" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} $${REQUIRED_AWSK8S} $${REQUIRED_AWSKOPS} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	elif [ "$(FLAVOUR)" = "awshelm" ]; then \
		for bin in $$( echo $${REQUIRED_BASE} $${REQUIRED_TOOLS} $${REQUIRED_AWS} $${REQUIRED_AWSK8S} $${REQUIRED_AWSHELM} ); do \
			if echo "$${BINS}" | grep -E "^$${bin}" >/dev/null; then \
				echo "[OK] required bin available: $${bin}"; \
			else \
				echo "[FAILED] required bin not available: $${bin}"; \
				exit 1; \
			fi; \
		done; \
	\
	fi; \
	echo "[SUCCESS]"; \
	echo

.PHONY: test-helm-version
test-helm-version:
	@echo "################################################################################"
	@echo "# Testing correct Helm version"
	@echo "################################################################################"
	@\
	if [ "$(FLAVOUR)" = "awshelm" ]; then \
		if echo '$(HELM)' | grep -Eq 'latest\-?'; then \
			echo "Fetching latest version from GitHub"; \
			LATEST="$$( \
				curl -L -sS https://github.com/helm/helm/releases \
					| tac | tac \
					| grep -Eo "helm/helm/releases/tag/v[.0-9]+\"" \
					| head -1 \
					| sed 's/.*v//g' \
					| sed 's/\"//g' \
			)"; \
			echo "Testing for latest: $${LATEST}"; \
			if ! docker run --rm $(IMAGE):$(ANSIBLE)-awshelm$(HELM) helm version --client --short | grep -E "^(Client: )?v$${LATEST}"; then \
				echo "[FAILED]"; \
				docker run --rm $(IMAGE):$(ANSIBLE)-awshelm$(HELM) helm version --client --short; \
				exit 1; \
			fi; \
		else \
			VERSION="$$( echo '$(HELM)' | grep -Eo '^[.0-9]+?' )"; \
			echo "Testing for version: $${VERSION}"; \
			if ! docker run --rm $(IMAGE):$(ANSIBLE)-awshelm$(HELM) helm version --client --short | grep -E "^(Client: )?v$${VERSION}\."; then \
				echo "[FAILED]"; \
				docker run --rm $(IMAGE):$(ANSIBLE)-awshelm$(HELM) helm version --client --short; \
				exit 1; \
			fi; \
		fi; \
		echo "[SUCCESS]"; \
	else \
		echo "[SKIPPING] Not a Helm image"; \
	fi; \
	echo

.PHONY: test-kops-version
test-kops-version:
	@echo "################################################################################"
	@echo "# Testing correct Kops version"
	@echo "################################################################################"
	@\
	if [ "$(FLAVOUR)" = "awskops" ]; then \
		if echo '$(KOPS)' | grep -Eq 'latest\-?'; then \
			echo "Fetching latest version from GitHub"; \
			LATEST="$$( \
				curl -L -sS https://github.com/kubernetes/kops/releases \
					| tac | tac \
					| grep -Eo "kubernetes/kops/releases/tag/v[.0-9]+\"" \
					| head -1 \
					| sed 's/.*v//g' \
					| sed 's/\"//g' \
			)"; \
			echo "Testing for latest: $${LATEST}"; \
			if ! docker run --rm $(IMAGE):$(ANSIBLE)-awskops$(KOPS) kops version | grep -E "^Version $${LATEST}"; then \
				echo "[FAILED]"; \
				docker run --rm $(IMAGE):$(ANSIBLE)-awskops$(KOPS) kops version; \
				exit 1; \
			fi; \
		else \
			VERSION="$$( echo '$(KOPS)' | grep -Eo '^[.0-9]+?' )"; \
			echo "Testing for version: $${VERSION}"; \
			if ! docker run --rm $(IMAGE):$(ANSIBLE)-awskops$(KOPS) kops version | grep -E "^Version $${VERSION}\."; then \
				echo "[FAILED]"; \
				docker run --rm $(IMAGE):$(ANSIBLE)-awskops$(KOPS) kops version; \
				exit 1; \
			fi; \
		fi; \
		echo "[SUCCESS]"; \
	else \
		echo "[SKIPPING] Not a Kops image"; \
	fi; \
	echo

.PHONY: test-run-user-root
test-run-user-root:
	@echo "################################################################################"
	@echo "# Testing playbook (user: root)"
	@echo "################################################################################"
	@\
	if [ "$(FLAVOUR)" = "base" ]; then \
		if ! docker run --rm $$(tty -s && echo "-it" || echo) -v $(CURRENT_DIR)/tests:/data $(IMAGE):$(ANSIBLE) ansible-playbook -i inventory playbook.yml; then \
			echo "[FAILED]"; \
			exit 1; \
		fi; \
	else \
		if ! docker run --rm $$(tty -s && echo "-it" || echo) -v $(CURRENT_DIR)/tests:/data $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(HELM)$(KOPS) ansible-playbook -i inventory playbook.yml ; then \
			echo "[FAILED]"; \
			exit 1; \
		fi; \
	fi; \
	echo "[SUCCESS]"; \
	echo

.PHONY: test-run-user-ansible
test-run-user-ansible:
	@echo "################################################################################"
	@echo "# Testing playbook (user: ansible)"
	@echo "################################################################################"
	@\
	if [ "$(FLAVOUR)" = "base" ]; then \
		echo "[SKIPPING] Does not have user setup"; \
	else \
		if ! docker run --rm $$(tty -s && echo "-it" || echo) -v $(CURRENT_DIR)/tests:/data -e USER=ansible -e MY_UID=$$(id -u) -e MY_GID=$$(id -g) $(IMAGE):$(ANSIBLE)-$(FLAVOUR)$(HELM)$(KOPS) ansible-playbook -i inventory playbook.yml ; then \
			echo "[FAILED]"; \
			exit 1; \
		fi; \
	fi; \
	echo "[SUCCESS]"; \
	echo
