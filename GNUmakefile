VERSION := v0.3.0
ARCH := amd64 arm

# Setup
TRAVIS_BUILD_NUMBER ?= 0
DEBVERSION := $(VERSION:v%=%)-$(TRAVIS_BUILD_NUMBER)
GOPATH := $(abspath gopath)
LOKIHOME := $(GOPATH)/src/github.com/grafana/loki

# Let's map from go architectures to deb architectures, because they're not the same!
DEB_arm_ARCH := armhf
DEB_amd64_ARCH := amd64

# CC Toolchain mapping
CC_FOR_LINUX_ARM := arm-linux-gnueabi-gcc

.EXPORT_ALL_VARIABLES:

.PHONY: package
package: $(addsuffix .deb, $(addprefix promtail_$(DEBVERSION)_, $(foreach a, $(ARCH), $(a))))

.PHONY: checkout
checkout: $(LOKIHOME)

$(GOPATH):
	mkdir $(GOPATH)

$(LOKIHOME): $(GOPATH)
	git clone https://github.com/grafana/loki $(LOKIHOME)
	cd $(LOKIHOME) && git checkout $(VERSION)

$(LOKIHOME)/dist/promtail_linux_%: $(LOKIHOME)
	cd $(LOKIHOME) && GOOS=linux GOARCH=$* go build -o dist/promtail_linux_$* ./cmd/promtail

promtail_$(DEBVERSION)_%.deb: $(LOKIHOME)/dist/promtail_linux_%
	bundle exec fpm -s dir -t deb -n promtail --description "Loki promtail log forwarder" --url https://github.com/grafana/loki/blob/master/docs/promtail.md --deb-changelog $(LOKIHOME)/CHANGELOG.md --prefix / -a $(DEB_$*_ARCH) -v $(DEBVERSION) --deb-systemd promtail.service --config-files /etc/promtail/promtail.yml promtail.yml=/etc/promtail/promtail.yml $<=/usr/bin/promtail

.PHONY: clean
clean:
	rm -f *.deb
	rm -rf $(GOPATH)
