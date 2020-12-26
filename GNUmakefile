DEBNAME := promtail
APP_REMOTE := github.com/grafana/loki
VERSION := v2.1.0
APPDESCRIPTION := Log agent for Loki
APPURL := https://github.com/grafana/loki/blob/master/docs/clients/promtail/
ARCH := amd64 arm arm64
GO_BUILD_SOURCE := ./cmd/promtail

# Setup
BUILD_NUMBER ?= 0
DEBVERSION := $(VERSION:v%=%)-$(BUILD_NUMBER)
GOPATH := $(abspath gopath)
APPHOME := $(GOPATH)/src/$(APP_REMOTE)

# Let's map from go architectures to deb architectures, because they're not the same!
DEB_arm_ARCH := armhf
DEB_arm64_ARCH := arm64
DEB_amd64_ARCH := amd64

# Version info for binaries
CGO_ENABLED := 1
GOARM := 6
VPREFIX := github.com/grafana/loki/pkg/build


GO_LDFLAGS = -s -w -X $(VPREFIX).Branch=$(GIT_BRANCH) -X $(VPREFIX).Version=$(IMAGE_TAG) -X $(VPREFIX).Revision=$(GIT_REVISION) -X $(VPREFIX).BuildUser=$(shell whoami)@$(shell hostname) -X $(VPREFIX).BuildDate=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
DYN_GO_FLAGS = -ldflags "$(GO_LDFLAGS)" -tags netgo -mod vendor

# CC Toolchain mapping
CC_FOR_linux_arm := arm-linux-gnueabi-gcc
CC_FOR_linux_arm64 := aarch64-linux-gnu-gcc
CC_FOR_linux_amd64 := gcc


.EXPORT_ALL_VARIABLES:

.PHONY: package
package: $(addsuffix .deb, $(addprefix $(DEBNAME)_$(DEBVERSION)_, $(foreach a, $(ARCH), $(a))))

.PHONY: build
build: $(addprefix $(APPHOME)/dist/$(DEBNAME)_linux_, $(foreach a, $(ARCH), $(a)))

.PHONY: checkout
checkout: $(APPHOME)

$(GOPATH):
	mkdir $(GOPATH)

$(APPHOME): $(GOPATH)
	git clone --depth 1 --branch $(VERSION) https://$(APP_REMOTE) $(APPHOME)
	cd $(APPHOME) && git checkout $(VERSION)

$(APPHOME)/dist/$(DEBNAME)_linux_%: $(APPHOME)
	$(eval GIT_REVISION := $(shell cd $(APPHOME) && git rev-parse --short HEAD))
	$(eval GIT_BRANCH := $(shell cd $(APPHOME) && git rev-parse --abbrev-ref HEAD))
	$(eval IMAGE_TAG := $(shell cd $(APPHOME) && ./tools/image-tag))
	cd $(APPHOME) && \
	CC=$(CC_FOR_linux_$*) GOOS=linux GOARCH=$* go build $(DYN_GO_FLAGS) -o dist/$(DEBNAME)_linux_$* $(GO_BUILD_SOURCE)
	upx $@

$(DEBNAME)_$(DEBVERSION)_%.deb: $(APPHOME)/dist/$(DEBNAME)_linux_%
	chmod +x $<
	bundle exec fpm -f -s dir -t deb --license Apache --deb-priority optional --maintainer github@growse.com --vendor https://grafana.com/ -n $(DEBNAME) --description "$(APPDESCRIPTION)" --url $(APPURL) --deb-changelog $(APPHOME)/CHANGELOG.md --prefix / -a $(DEB_$*_ARCH) -v $(DEBVERSION) --before-install deb_scripts/before_install.sh --before-upgrade deb_scripts/before_upgrade.sh --after-remove deb_scripts/after_remove.sh --deb-systemd promtail.service --config-files /etc/promtail/promtail.yml promtail.yml=/etc/promtail/promtail.yml $<=/usr/bin/promtail

.PHONY: clean
clean:
	rm -f *.deb
	rm -rf $(GOPATH)
