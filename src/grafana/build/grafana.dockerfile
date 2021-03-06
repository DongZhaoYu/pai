# Copyright (c) Microsoft Corporation
# All rights reserved.
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


FROM debian:jessie

ENV \
  GRAFANA_VERSION=4.6.3 \
  GF_PLUGIN_DIR=/grafana-plugins \
  GF_PATHS_LOGS=/var/log/grafana \
  GF_PATHS_DATA=/var/lib/grafana \
  UPGRADEALL=true


COPY src/run.sh src/grafana_config.sh src/start_server.sh /usr/local/
COPY src/dashboards/* /usr/local/grafana/dashboards/

RUN \
  apt-get update && \
  apt-get -y --force-yes --no-install-recommends install libfontconfig curl ca-certificates git jq && \
  curl https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_${GRAFANA_VERSION}_amd64.deb > /tmp/grafana.deb && \
  dpkg -i /tmp/grafana.deb && \
  rm -f /tmp/grafana.deb && \
  for plugin in $(curl -s https://grafana.net/api/plugins?orderBy=name | jq '.items[] | select(.internal=='false') | .slug' | tr -d '"'); do grafana-cli --pluginsDir "${GF_PLUGIN_DIR}" plugins install $plugin; done && \
  ### branding && \
  chmod 777 /usr/local/run.sh /usr/local/grafana_config.sh /usr/local/start_server.sh && \
  apt-get remove -y --force-yes git jq && \
  apt-get autoremove -y --force-yes && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*


ENTRYPOINT ["/usr/local/run.sh"]
