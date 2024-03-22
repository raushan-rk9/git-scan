#
# Usage:
# docker build -t awc/cms .
# docker run -dt --name <customname> --restart=always --network <networkname> -p <port>:80 -p <debugport>:3000 -e 'RAILS_ENV=production' -e 'DBNAME=railsdb' -e 'DBPASSWD=railsdb' -v $(pwd):/app awc/cms
#

FROM ruby:3.0

RUN apt update; apt install -y apt-transport-https gcc g++ make
RUN curl -sL https://deb.nodesource.com/setup_17.x | bash -
RUN apt install -y nodejs
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update; apt install -y yarn
RUN apt update; apt install nano
RUN apt update; apt install telnet
RUN apt update; apt install net-tools
RUN gem install rails

# Expose the current folder to docker.
VOLUME ["/app"]

ENV RAILS_ENV="production" DBUSER=railsdb DBNAME=railsdb DBPASSWD=railsdb
WORKDIR /app
EXPOSE 62100:80 62101:443

CMD ["/app/scripts/startup.sh"]
