FROM ubuntu:24.04
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y ca-certificates cmake dpkg-dev gettext g++-mingw-w64-i686 g++-mingw-w64-x86-64 git libz-mingw-w64-dev pkg-config-mingw-w64-i686 pkg-config-mingw-w64-x86-64 smpq tzdata wget
WORKDIR /builddevx

# Fix libz.dll
RUN rm /usr/i686-w64-mingw32/lib/libz.dll.a
RUN rm /usr/x86_64-w64-mingw32/lib/libz.dll.a

# Setup SDL2
RUN wget -q https://github.com/libsdl-org/SDL/releases/download/release-2.32.6/SDL2-devel-2.32.6-mingw.tar.gz -OSDL2-devel-mingw.tar.gz \
    && tar -xzf SDL2-devel-mingw.tar.gz \
    && cp -r SDL2*/i686-w64-mingw32/* /usr/i686-w64-mingw32 \
    && cp -r SDL2*/x86_64-w64-mingw32/* /usr/x86_64-w64-mingw32

# Setup SDL1 for Win9x
RUN wget -q https://www.libsdl.org/release/SDL-devel-1.2.15-mingw32.tar.gz -OSDL-devel-1.2.15-mingw32.tar.gz \
    && tar -xzf SDL-devel-1.2.15-mingw32.tar.gz \
    && cp -r SDL-*/include/* /usr/i686-w64-mingw32/include \
    && cp -r SDL-*/lib/* /usr/i686-w64-mingw32/lib \
    && cp -r SDL-*/bin/* /usr/i686-w64-mingw32/bin

# Setup libsodium
RUN wget -q https://github.com/jedisct1/libsodium/releases/download/1.0.20-RELEASE/libsodium-1.0.20-mingw.tar.gz -Olibsodium-1.0.20-mingw.tar.gz \
    && tar -xzf libsodium-1.0.20-mingw.tar.gz --no-same-owner \
    && cp -r libsodium-win32/* /usr/i686-w64-mingw32 \
    && cp -r libsodium-win64/* /usr/x86_64-w64-mingw32

# Fixup pkgconfig prefix:
RUN find "/usr/i686-w64-mingw32/lib/pkgconfig/" -name '*.pc' -exec sed -i "s|^prefix=.*|prefix=/usr/i686-w64-mingw32|" '{}' \;
RUN find "/usr/x86_64-w64-mingw32/lib/pkgconfig/" -name '*.pc' -exec sed -i "s|^prefix=.*|prefix=/usr/x86_64-w64-mingw32|" '{}' \;

# Fixup CMake prefix:
RUN find "/usr/i686-w64-mingw32" -name '*.cmake' -exec sed -i "s|/opt/local/i686-w64-mingw32|/usr/i686-w64-mingw32|" '{}' \;
RUN find "/usr/x86_64-w64-mingw32" -name '*.cmake' -exec sed -i "s|/opt/local//x86_64-w64-mingw32|/usr/x86_64-w64-mingw32|" '{}' \;

RUN rm -rf /builddevx/*

RUN git config --global --add safe.directory '*'
