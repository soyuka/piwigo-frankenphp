FROM dunglas/frankenphp:1.11.2-php8.5-bookworm

WORKDIR /app

# add additional extensions here:
RUN install-php-extensions \
	curl \
  apcu \
  pdo_mysql \
  mysqli \
  xml \
  exif \
  zip \
	opcache

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    exiftool \
    ffmpeg \
    imagemagick \
    libimage-exiftool-perl \
    libjpeg-turbo-progs \
    mediainfo \
    poppler-utils \
    re2c \
    unzip \
    curl && \
  if [ -z ${PIWIGO_RELEASE+x} ]; then \
    PIWIGO_RELEASE=$(curl -sX GET "https://api.github.com/repos/Piwigo/Piwigo/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  mkdir -p /app/public && \
  curl -o \
    /tmp/piwigo.zip -L \
    "https://piwigo.org/download/dlcounter.php?code=${PIWIGO_RELEASE}" && \
  unzip -q /tmp/piwigo.zip -d /tmp && \
  mv /tmp/piwigo/* /app/public && \
  rm -rf \
    /tmp/* && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY root/ /

RUN cp $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

EXPOSE 80 443
VOLUME /public/config /public/local /public/plugins /public/template-extension /public/themes /public/upload /public/galleries
