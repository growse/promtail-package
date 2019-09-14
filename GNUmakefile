VERSION := v0.3.0

GOPATH := $(abspath gopath)
LOKIHOME := $(GOPATH)/src/github.com/grafana/loki
ARCH := amd64
DEBNAME := promtail_$(VERSION)_$(ARCH).deb

.PHONY: package
package: $(DEBNAME)

.PHONY: build
build: $(LOKIHOME)/cmd/promtail/promtail

.PHONY: checkout
checkout: $(LOKIHOME)

$(LOKIHOME):
	mkdir $(GOPATH)
	git clone https://github.com/grafana/loki $(LOKIHOME)
	cd $(LOKIHOME) && git checkout $(VERSION)

$(LOKIHOME)/cmd/promtail/promtail: $(LOKIHOME)
	make -C "$(LOKIHOME)" promtail

usr/bin/promtail: $(LOKIHOME)/cmd/promtail/promtail
	mkdir -p usr/bin && cp $(LOKIHOME)/cmd/promtail/promtail usr/bin/promtail

$(DEBNAME): usr/bin/promtail
	bundle exec fpm -s dir -t deb -n promtail --description "Loki promtail log forwarder" --url https://github.com/grafana/loki/blob/master/docs/promtail.md --prefix / -a $(ARCH) -v $(VERSION) --deb-systemd lib/systemd/system/promtail.service --config-files /etc/promtail/promtail.yml etc usr
