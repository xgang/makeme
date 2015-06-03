#
#   me-macosx-default.mk -- Makefile to build Embedthis MakeMe for macosx
#

NAME                  := me
VERSION               := 0.8.8
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= macosx
CC                    ?= clang
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_COMPILER       ?= 1
ME_COM_EJS            ?= 1
ME_COM_EST            ?= 0
ME_COM_HTTP           ?= 1
ME_COM_LIB            ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MBEDTLS        ?= 0
ME_COM_MPR            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 1

ME_COM_OPENSSL_PATH   ?= "/usr/lib"

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_EJS),1)
    ME_COM_ZLIB := 1
endif

CFLAGS                += -g -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MBEDTLS=$(ME_COM_MBEDTLS) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS              += -L$(BUILD)/bin
LIBS                  += -ldl -lpthread -lm

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs.mod
endif
TARGETS               += $(BUILD)/bin/ejs.testme.es
TARGETS               += $(BUILD)/bin/ejs.testme.mod
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs
endif
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += $(BUILD)/bin/http
endif
ifeq ($(ME_COM_SSL),1)
    TARGETS           += $(BUILD)/.install-certs-modified
endif
TARGETS               += $(BUILD)/bin/libtestme.dylib
TARGETS               += $(BUILD)/bin/me
TARGETS               += $(BUILD)/bin/testme
TARGETS               += $(BUILD)/bin/testme.es

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/me-macosx-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/me-macosx-default-me.h >/dev/null ; then\
		cp projects/me-macosx-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build" ; \
			echo "   [Warning] Previous build command: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/ejs.o"
	rm -f "$(BUILD)/obj/ejsLib.o"
	rm -f "$(BUILD)/obj/ejsc.o"
	rm -f "$(BUILD)/obj/est.o"
	rm -f "$(BUILD)/obj/estLib.o"
	rm -f "$(BUILD)/obj/http.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/libtestme.o"
	rm -f "$(BUILD)/obj/me.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/openssl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/removeFiles.o"
	rm -f "$(BUILD)/obj/testme.o"
	rm -f "$(BUILD)/obj/zlib.o"
	rm -f "$(BUILD)/bin/ejs.testme.es"
	rm -f "$(BUILD)/bin/ejsc"
	rm -f "$(BUILD)/bin/ejs"
	rm -f "$(BUILD)/bin/http"
	rm -f "$(BUILD)/.install-certs-modified"
	rm -f "$(BUILD)/bin/libejs.dylib"
	rm -f "$(BUILD)/bin/libhttp.dylib"
	rm -f "$(BUILD)/bin/libmpr.dylib"
	rm -f "$(BUILD)/bin/libpcre.dylib"
	rm -f "$(BUILD)/bin/libtestme.dylib"
	rm -f "$(BUILD)/bin/libzlib.dylib"
	rm -f "$(BUILD)/bin/libmpr-openssl.a"
	rm -f "$(BUILD)/bin/testme"
	rm -f "$(BUILD)/bin/testme.es"

clobber: clean
	rm -fr ./$(BUILD)

#
#   init
#

init: $(DEPS_1)
	if [ ! -d /usr/include/openssl ] ; then echo ; \
	echo Install libssl-dev to get /usr/include/openssl ; \
	exit 255 ; \
	fi

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_2)

#
#   osdep.h
#
DEPS_3 += src/osdep/osdep.h
DEPS_3 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_4 += src/mpr/mpr.h
DEPS_4 += $(BUILD)/inc/me.h
DEPS_4 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_5 += src/http/http.h
DEPS_5 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_5)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/http/http.h $(BUILD)/inc/http.h

#
#   ejs.slots.h
#
DEPS_6 += src/ejs/ejs.slots.h

$(BUILD)/inc/ejs.slots.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/ejs.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejs.slots.h $(BUILD)/inc/ejs.slots.h

#
#   pcre.h
#
DEPS_7 += src/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   zlib.h
#
DEPS_8 += src/zlib/zlib.h
DEPS_8 += $(BUILD)/inc/me.h

$(BUILD)/inc/zlib.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   ejs.h
#
DEPS_9 += src/ejs/ejs.h
DEPS_9 += $(BUILD)/inc/me.h
DEPS_9 += $(BUILD)/inc/osdep.h
DEPS_9 += $(BUILD)/inc/mpr.h
DEPS_9 += $(BUILD)/inc/http.h
DEPS_9 += $(BUILD)/inc/ejs.slots.h
DEPS_9 += $(BUILD)/inc/pcre.h
DEPS_9 += $(BUILD)/inc/zlib.h

$(BUILD)/inc/ejs.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/ejs.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejs.h $(BUILD)/inc/ejs.h

#
#   ejsByteGoto.h
#
DEPS_10 += src/ejs/ejsByteGoto.h

$(BUILD)/inc/ejsByteGoto.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/ejsByteGoto.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejsByteGoto.h $(BUILD)/inc/ejsByteGoto.h

#
#   est.h
#
DEPS_11 += src/est/est.h

$(BUILD)/inc/est.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/est.h'
	mkdir -p "$(BUILD)/inc"
	cp src/est/est.h $(BUILD)/inc/est.h

#
#   testme.h
#
DEPS_12 += src/tm/testme.h
DEPS_12 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/testme.h: $(DEPS_12)
	@echo '      [Copy] $(BUILD)/inc/testme.h'
	mkdir -p "$(BUILD)/inc"
	cp src/tm/testme.h $(BUILD)/inc/testme.h

#
#   ejs.o
#
DEPS_13 += $(BUILD)/inc/ejs.h

$(BUILD)/obj/ejs.o: \
    src/ejs/ejs.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/ejs.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejs.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/ejs/ejs.c

#
#   ejsLib.o
#
DEPS_14 += $(BUILD)/inc/ejs.h
DEPS_14 += $(BUILD)/inc/mpr.h
DEPS_14 += $(BUILD)/inc/pcre.h
DEPS_14 += $(BUILD)/inc/me.h

$(BUILD)/obj/ejsLib.o: \
    src/ejs/ejsLib.c $(DEPS_14)
	@echo '   [Compile] $(BUILD)/obj/ejsLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsLib.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/ejs/ejsLib.c

#
#   ejsc.o
#
DEPS_15 += $(BUILD)/inc/ejs.h

$(BUILD)/obj/ejsc.o: \
    src/ejs/ejsc.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/ejsc.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsc.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/ejs/ejsc.c

#
#   est.o
#
DEPS_16 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/est.o: \
    src/mpr-est/est.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/est.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/est.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/mpr-est/est.c

#
#   est.h
#

src/est/est.h: $(DEPS_17)

#
#   estLib.o
#
DEPS_18 += src/est/est.h

$(BUILD)/obj/estLib.o: \
    src/est/estLib.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/estLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/estLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/est/estLib.c

#
#   http.o
#
DEPS_19 += $(BUILD)/inc/http.h

$(BUILD)/obj/http.o: \
    src/http/http.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/http.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/http/http.c

#
#   httpLib.o
#
DEPS_20 += $(BUILD)/inc/http.h
DEPS_20 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/http/httpLib.c

#
#   libtestme.o
#
DEPS_21 += $(BUILD)/inc/testme.h

$(BUILD)/obj/libtestme.o: \
    src/tm/libtestme.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/libtestme.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/libtestme.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/tm/libtestme.c

#
#   me.o
#
DEPS_22 += $(BUILD)/inc/ejs.h

$(BUILD)/obj/me.o: \
    src/me.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/me.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/me.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/me.c

#
#   mprLib.o
#
DEPS_23 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr/mprLib.c

#
#   openssl.o
#
DEPS_24 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/openssl.o: \
    src/mpr-openssl/openssl.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/openssl.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/openssl.o -arch $(CC_ARCH) -Wno-deprecated-declarations -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr-openssl/openssl.c

#
#   pcre.o
#
DEPS_25 += $(BUILD)/inc/me.h
DEPS_25 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/pcre/pcre.c

#
#   removeFiles.o
#

$(BUILD)/obj/removeFiles.o: \
    package/windows/removeFiles.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/removeFiles.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/removeFiles.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) package/windows/removeFiles.c

#
#   testme.o
#
DEPS_27 += $(BUILD)/inc/ejs.h

$(BUILD)/obj/testme.o: \
    src/tm/testme.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/testme.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/testme.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/tm/testme.c

#
#   zlib.o
#
DEPS_28 += $(BUILD)/inc/me.h
DEPS_28 += $(BUILD)/inc/zlib.h

$(BUILD)/obj/zlib.o: \
    src/zlib/zlib.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/zlib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/zlib/zlib.c

ifeq ($(ME_COM_SSL),1)
#
#   openssl
#
DEPS_29 += $(BUILD)/obj/openssl.o

$(BUILD)/bin/libmpr-openssl.a: $(DEPS_29)
	@echo '      [Link] $(BUILD)/bin/libmpr-openssl.a'
	ar -cr $(BUILD)/bin/libmpr-openssl.a "$(BUILD)/obj/openssl.o"
endif

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_30 += $(BUILD)/inc/osdep.h
DEPS_30 += $(BUILD)/inc/est.h
DEPS_30 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.a: $(DEPS_30)
	@echo '      [Link] $(BUILD)/bin/libest.a'
	ar -cr $(BUILD)/bin/libest.a "$(BUILD)/obj/estLib.o"
endif

ifeq ($(ME_COM_SSL),1)
#
#   est
#
ifeq ($(ME_COM_EST),1)
    DEPS_31 += $(BUILD)/bin/libest.a
endif
DEPS_31 += $(BUILD)/obj/est.o

$(BUILD)/bin/libmpr-estssl.a: $(DEPS_31)
	@echo '      [Link] $(BUILD)/bin/libmpr-estssl.a'
	ar -cr $(BUILD)/bin/libmpr-estssl.a "$(BUILD)/obj/est.o"
endif

#
#   libmpr
#
DEPS_32 += $(BUILD)/inc/osdep.h
ifeq ($(ME_COM_SSL),1)
ifeq ($(ME_COM_OPENSSL),1)
    DEPS_32 += $(BUILD)/bin/libmpr-openssl.a
endif
endif
ifeq ($(ME_COM_SSL),1)
ifeq ($(ME_COM_EST),1)
    DEPS_32 += $(BUILD)/bin/libmpr-estssl.a
endif
endif
DEPS_32 += $(BUILD)/inc/mpr.h
DEPS_32 += $(BUILD)/obj/mprLib.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_32 += -lmpr-openssl
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_32 += -lssl
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_32 += -lcrypto
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_32 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_32 += -lmpr-estssl
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_32 += -lmpr-openssl
    LIBPATHS_32 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libmpr.dylib: $(DEPS_32)
	@echo '      [Link] $(BUILD)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libmpr.dylib -compatibility_version 0.8 -current_version 0.8 "$(BUILD)/obj/mprLib.o" $(LIBPATHS_32) $(LIBS_32) $(LIBS_32) $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_33 += $(BUILD)/inc/pcre.h
DEPS_33 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.dylib: $(DEPS_33)
	@echo '      [Link] $(BUILD)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 0.8 -current_version 0.8 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 0.8 -current_version 0.8 "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_34 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_PCRE),1)
    DEPS_34 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_34 += $(BUILD)/inc/http.h
DEPS_34 += $(BUILD)/obj/httpLib.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_34 += -lmpr-openssl
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_34 += -lssl
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_34 += -lcrypto
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_34 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_34 += -lmpr-estssl
endif
LIBS_34 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_34 += -lmpr-openssl
    LIBPATHS_34 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_34 += -lpcre
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_34 += -lpcre
endif
LIBS_34 += -lmpr

$(BUILD)/bin/libhttp.dylib: $(DEPS_34)
	@echo '      [Link] $(BUILD)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libhttp.dylib -compatibility_version 0.8 -current_version 0.8 "$(BUILD)/obj/httpLib.o" $(LIBPATHS_34) $(LIBS_34) $(LIBS_34) $(LIBS) 
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_35 += $(BUILD)/inc/zlib.h
DEPS_35 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.dylib: $(DEPS_35)
	@echo '      [Link] $(BUILD)/bin/libzlib.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libzlib.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libzlib.dylib -compatibility_version 0.8 -current_version 0.8 "$(BUILD)/obj/zlib.o" $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_36 += $(BUILD)/bin/libhttp.dylib
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_36 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_36 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_ZLIB),1)
    DEPS_36 += $(BUILD)/bin/libzlib.dylib
endif
DEPS_36 += $(BUILD)/inc/ejs.h
DEPS_36 += $(BUILD)/inc/ejs.slots.h
DEPS_36 += $(BUILD)/inc/ejsByteGoto.h
DEPS_36 += $(BUILD)/obj/ejsLib.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_36 += -lmpr-openssl
    LIBPATHS_36 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_36 += -lssl
    LIBPATHS_36 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_36 += -lcrypto
    LIBPATHS_36 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_36 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_36 += -lmpr-estssl
endif
LIBS_36 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_36 += -lmpr-openssl
    LIBPATHS_36 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_36 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_36 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_36 += -lpcre
endif
LIBS_36 += -lmpr
ifeq ($(ME_COM_ZLIB),1)
    LIBS_36 += -lzlib
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_36 += -lzlib
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_36 += -lhttp
endif

$(BUILD)/bin/libejs.dylib: $(DEPS_36)
	@echo '      [Link] $(BUILD)/bin/libejs.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libejs.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libejs.dylib -compatibility_version 0.8 -current_version 0.8 "$(BUILD)/obj/ejsLib.o" $(LIBPATHS_36) $(LIBS_36) $(LIBS_36) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_37 += $(BUILD)/bin/libejs.dylib
DEPS_37 += $(BUILD)/obj/ejsc.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_37 += -lmpr-openssl
    LIBPATHS_37 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_37 += -lssl
    LIBPATHS_37 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_37 += -lcrypto
    LIBPATHS_37 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_37 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_37 += -lmpr-estssl
endif
LIBS_37 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_37 += -lmpr-openssl
    LIBPATHS_37 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_37 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_37 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_37 += -lpcre
endif
LIBS_37 += -lmpr
ifeq ($(ME_COM_ZLIB),1)
    LIBS_37 += -lzlib
endif
LIBS_37 += -lejs
ifeq ($(ME_COM_ZLIB),1)
    LIBS_37 += -lzlib
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_37 += -lhttp
endif

$(BUILD)/bin/ejsc: $(DEPS_37)
	@echo '      [Link] $(BUILD)/bin/ejsc'
	$(CC) -o $(BUILD)/bin/ejsc -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/ejsc.o" $(LIBPATHS_37) $(LIBS_37) $(LIBS_37) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_38 += src/ejs/ejs.es
DEPS_38 += $(BUILD)/bin/ejsc

$(BUILD)/bin/ejs.mod: $(DEPS_38)
	( \
	cd src/ejs; \
	echo '   [Compile] ejs.mod' ; \
	"../../$(BUILD)/bin/ejsc" --out "../../$(BUILD)/bin/ejs.mod" --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   ejs.testme.es
#
DEPS_39 += src/tm/ejs.testme.es

$(BUILD)/bin/ejs.testme.es: $(DEPS_39)
	@echo '      [Copy] $(BUILD)/bin/ejs.testme.es'
	mkdir -p "$(BUILD)/bin"
	cp src/tm/ejs.testme.es $(BUILD)/bin/ejs.testme.es

#
#   ejs.testme.mod
#
DEPS_40 += src/tm/ejs.testme.es
ifeq ($(ME_COM_EJS),1)
    DEPS_40 += $(BUILD)/bin/ejs.mod
endif

$(BUILD)/bin/ejs.testme.mod: $(DEPS_40)
	( \
	cd src/tm; \
	echo '   [Compile] ejs.testme.mod' ; \
	"../../$(BUILD)/bin/ejsc" --debug --out "../../$(BUILD)/bin/ejs.testme.mod" --optimize 9 ejs.testme.es ; \
	)

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_41 += $(BUILD)/bin/libejs.dylib
DEPS_41 += $(BUILD)/obj/ejs.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_41 += -lmpr-openssl
    LIBPATHS_41 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_41 += -lssl
    LIBPATHS_41 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_41 += -lcrypto
    LIBPATHS_41 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_41 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_41 += -lmpr-estssl
endif
LIBS_41 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_41 += -lmpr-openssl
    LIBPATHS_41 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_41 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_41 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_41 += -lpcre
endif
LIBS_41 += -lmpr
ifeq ($(ME_COM_ZLIB),1)
    LIBS_41 += -lzlib
endif
LIBS_41 += -lejs
ifeq ($(ME_COM_ZLIB),1)
    LIBS_41 += -lzlib
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_41 += -lhttp
endif

$(BUILD)/bin/ejs: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/ejs'
	$(CC) -o $(BUILD)/bin/ejs -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/ejs.o" $(LIBPATHS_41) $(LIBS_41) $(LIBS_41) $(LIBS) -ledit 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_42 += $(BUILD)/bin/libhttp.dylib
DEPS_42 += $(BUILD)/obj/http.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_42 += -lmpr-openssl
    LIBPATHS_42 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_42 += -lssl
    LIBPATHS_42 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_42 += -lcrypto
    LIBPATHS_42 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_42 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_42 += -lmpr-estssl
endif
LIBS_42 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_42 += -lmpr-openssl
    LIBPATHS_42 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_42 += -lpcre
endif
LIBS_42 += -lhttp
ifeq ($(ME_COM_PCRE),1)
    LIBS_42 += -lpcre
endif
LIBS_42 += -lmpr

$(BUILD)/bin/http: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/http'
	$(CC) -o $(BUILD)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/http.o" $(LIBPATHS_42) $(LIBS_42) $(LIBS_42) $(LIBS) 
endif

#
#   import-certs
#

import-certs: $(DEPS_43)

ifeq ($(ME_COM_SSL),1)
#
#   install-certs
#
DEPS_44 += src/certs/samples/ca.crt
DEPS_44 += src/certs/samples/ca.key
DEPS_44 += src/certs/samples/dh.pem
DEPS_44 += src/certs/samples/ec.crt
DEPS_44 += src/certs/samples/ec.key
DEPS_44 += src/certs/samples/roots.crt
DEPS_44 += src/certs/samples/self.crt
DEPS_44 += src/certs/samples/self.key
DEPS_44 += src/certs/samples/test.crt
DEPS_44 += src/certs/samples/test.key

$(BUILD)/.install-certs-modified: $(DEPS_44)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin"
	cp src/certs/samples/ca.crt $(BUILD)/bin/ca.crt
	cp src/certs/samples/ca.key $(BUILD)/bin/ca.key
	cp src/certs/samples/dh.pem $(BUILD)/bin/dh.pem
	cp src/certs/samples/ec.crt $(BUILD)/bin/ec.crt
	cp src/certs/samples/ec.key $(BUILD)/bin/ec.key
	cp src/certs/samples/roots.crt $(BUILD)/bin/roots.crt
	cp src/certs/samples/self.crt $(BUILD)/bin/self.crt
	cp src/certs/samples/self.key $(BUILD)/bin/self.key
	cp src/certs/samples/test.crt $(BUILD)/bin/test.crt
	cp src/certs/samples/test.key $(BUILD)/bin/test.key
	touch "$(BUILD)/.install-certs-modified"
endif

#
#   libtestme
#
DEPS_45 += $(BUILD)/inc/testme.h
DEPS_45 += $(BUILD)/obj/libtestme.o

$(BUILD)/bin/libtestme.dylib: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libtestme.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libtestme.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libtestme.dylib -compatibility_version 0.8 -current_version 0.8 "$(BUILD)/obj/libtestme.o" $(LIBS) 

#
#   me.mod
#
DEPS_46 += src/Builder.es
DEPS_46 += src/Loader.es
DEPS_46 += src/MakeMe.es
DEPS_46 += src/Me.es
DEPS_46 += src/Script.es
DEPS_46 += src/Target.es
DEPS_46 += paks/ejs-version/Version.es
ifeq ($(ME_COM_EJS),1)
    DEPS_46 += $(BUILD)/bin/ejs.mod
endif

$(BUILD)/bin/me.mod: $(DEPS_46)
	echo '   [Compile] me.mod' ; \
	"./$(BUILD)/bin/ejsc" --debug --out "./$(BUILD)/bin/me.mod" --optimize 9 src/Builder.es src/Loader.es src/MakeMe.es src/Me.es src/Script.es src/Target.es paks/ejs-version/Version.es

#
#   pakrun
#
DEPS_47 += paks/me-components/appweb.me
DEPS_47 += paks/me-components/compiler.me
DEPS_47 += paks/me-components/components.me
DEPS_47 += paks/me-components/lib.me
DEPS_47 += paks/me-components/LICENSE.md
DEPS_47 += paks/me-components/link.me
DEPS_47 += paks/me-components/package.json
DEPS_47 += paks/me-components/rc.me
DEPS_47 += paks/me-components/README.md
DEPS_47 += paks/me-components/testme.me
DEPS_47 += paks/me-components/vxworks.me
DEPS_47 += paks/me-components/winsdk.me
DEPS_47 += paks/me-configuration/Configuration.es
DEPS_47 += paks/me-configuration/configuration.me
DEPS_47 += paks/me-configuration/LICENSE.md
DEPS_47 += paks/me-configuration/package.json
DEPS_47 += paks/me-configuration/README.md
DEPS_47 += paks/me-installs/Installs.es
DEPS_47 += paks/me-installs/installs.me
DEPS_47 += paks/me-installs/LICENSE.md
DEPS_47 += paks/me-installs/manifest.me
DEPS_47 += paks/me-installs/package.json
DEPS_47 += paks/me-installs/README.md
DEPS_47 += paks/me-os/freebsd.me
DEPS_47 += paks/me-os/gcc.me
DEPS_47 += paks/me-os/LICENSE.md
DEPS_47 += paks/me-os/linux.me
DEPS_47 += paks/me-os/macosx.me
DEPS_47 += paks/me-os/os.me
DEPS_47 += paks/me-os/package.json
DEPS_47 += paks/me-os/README.md
DEPS_47 += paks/me-os/solaris.me
DEPS_47 += paks/me-os/unix.me
DEPS_47 += paks/me-os/vxworks.me
DEPS_47 += paks/me-os/windows.me
DEPS_47 += paks/me-project/LICENSE.md
DEPS_47 += paks/me-project/package.json
DEPS_47 += paks/me-project/Project.es
DEPS_47 += paks/me-project/project.me
DEPS_47 += paks/me-project/README.md
DEPS_47 += paks/me-vstudio/LICENSE.md
DEPS_47 += paks/me-vstudio/package.json
DEPS_47 += paks/me-vstudio/README.md
DEPS_47 += paks/me-vstudio/Vstudio.es
DEPS_47 += paks/me-vstudio/vstudio.me
DEPS_47 += paks/me-xcode/LICENSE.md
DEPS_47 += paks/me-xcode/package.json
DEPS_47 += paks/me-xcode/README.md
DEPS_47 += paks/me-xcode/Xcode.es
DEPS_47 += paks/me-xcode/xcode.me

$(BUILD)/.pakrun-modified: $(DEPS_47)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin/paks/me-components"
	cp paks/me-components/appweb.me $(BUILD)/bin/paks/me-components/appweb.me
	cp paks/me-components/compiler.me $(BUILD)/bin/paks/me-components/compiler.me
	cp paks/me-components/components.me $(BUILD)/bin/paks/me-components/components.me
	cp paks/me-components/lib.me $(BUILD)/bin/paks/me-components/lib.me
	cp paks/me-components/LICENSE.md $(BUILD)/bin/paks/me-components/LICENSE.md
	cp paks/me-components/link.me $(BUILD)/bin/paks/me-components/link.me
	cp paks/me-components/package.json $(BUILD)/bin/paks/me-components/package.json
	cp paks/me-components/rc.me $(BUILD)/bin/paks/me-components/rc.me
	cp paks/me-components/README.md $(BUILD)/bin/paks/me-components/README.md
	cp paks/me-components/testme.me $(BUILD)/bin/paks/me-components/testme.me
	cp paks/me-components/vxworks.me $(BUILD)/bin/paks/me-components/vxworks.me
	cp paks/me-components/winsdk.me $(BUILD)/bin/paks/me-components/winsdk.me
	mkdir -p "$(BUILD)/bin/paks/me-configuration"
	cp paks/me-configuration/Configuration.es $(BUILD)/bin/paks/me-configuration/Configuration.es
	cp paks/me-configuration/configuration.me $(BUILD)/bin/paks/me-configuration/configuration.me
	cp paks/me-configuration/LICENSE.md $(BUILD)/bin/paks/me-configuration/LICENSE.md
	cp paks/me-configuration/package.json $(BUILD)/bin/paks/me-configuration/package.json
	cp paks/me-configuration/README.md $(BUILD)/bin/paks/me-configuration/README.md
	mkdir -p "$(BUILD)/bin/paks/me-installs"
	cp paks/me-installs/Installs.es $(BUILD)/bin/paks/me-installs/Installs.es
	cp paks/me-installs/installs.me $(BUILD)/bin/paks/me-installs/installs.me
	cp paks/me-installs/LICENSE.md $(BUILD)/bin/paks/me-installs/LICENSE.md
	cp paks/me-installs/manifest.me $(BUILD)/bin/paks/me-installs/manifest.me
	cp paks/me-installs/package.json $(BUILD)/bin/paks/me-installs/package.json
	cp paks/me-installs/README.md $(BUILD)/bin/paks/me-installs/README.md
	mkdir -p "$(BUILD)/bin/paks/me-os"
	cp paks/me-os/freebsd.me $(BUILD)/bin/paks/me-os/freebsd.me
	cp paks/me-os/gcc.me $(BUILD)/bin/paks/me-os/gcc.me
	cp paks/me-os/LICENSE.md $(BUILD)/bin/paks/me-os/LICENSE.md
	cp paks/me-os/linux.me $(BUILD)/bin/paks/me-os/linux.me
	cp paks/me-os/macosx.me $(BUILD)/bin/paks/me-os/macosx.me
	cp paks/me-os/os.me $(BUILD)/bin/paks/me-os/os.me
	cp paks/me-os/package.json $(BUILD)/bin/paks/me-os/package.json
	cp paks/me-os/README.md $(BUILD)/bin/paks/me-os/README.md
	cp paks/me-os/solaris.me $(BUILD)/bin/paks/me-os/solaris.me
	cp paks/me-os/unix.me $(BUILD)/bin/paks/me-os/unix.me
	cp paks/me-os/vxworks.me $(BUILD)/bin/paks/me-os/vxworks.me
	cp paks/me-os/windows.me $(BUILD)/bin/paks/me-os/windows.me
	mkdir -p "$(BUILD)/bin/paks/me-project"
	cp paks/me-project/LICENSE.md $(BUILD)/bin/paks/me-project/LICENSE.md
	cp paks/me-project/package.json $(BUILD)/bin/paks/me-project/package.json
	cp paks/me-project/Project.es $(BUILD)/bin/paks/me-project/Project.es
	cp paks/me-project/project.me $(BUILD)/bin/paks/me-project/project.me
	cp paks/me-project/README.md $(BUILD)/bin/paks/me-project/README.md
	mkdir -p "$(BUILD)/bin/paks/me-vstudio"
	cp paks/me-vstudio/LICENSE.md $(BUILD)/bin/paks/me-vstudio/LICENSE.md
	cp paks/me-vstudio/package.json $(BUILD)/bin/paks/me-vstudio/package.json
	cp paks/me-vstudio/README.md $(BUILD)/bin/paks/me-vstudio/README.md
	cp paks/me-vstudio/Vstudio.es $(BUILD)/bin/paks/me-vstudio/Vstudio.es
	cp paks/me-vstudio/vstudio.me $(BUILD)/bin/paks/me-vstudio/vstudio.me
	mkdir -p "$(BUILD)/bin/paks/me-xcode"
	cp paks/me-xcode/LICENSE.md $(BUILD)/bin/paks/me-xcode/LICENSE.md
	cp paks/me-xcode/package.json $(BUILD)/bin/paks/me-xcode/package.json
	cp paks/me-xcode/README.md $(BUILD)/bin/paks/me-xcode/README.md
	cp paks/me-xcode/Xcode.es $(BUILD)/bin/paks/me-xcode/Xcode.es
	cp paks/me-xcode/xcode.me $(BUILD)/bin/paks/me-xcode/xcode.me
	touch "$(BUILD)/.pakrun-modified"

#
#   runtime
#
DEPS_48 += src/master-main.me
DEPS_48 += src/master-start.me
DEPS_48 += src/simple.me
DEPS_48 += src/standard.me
DEPS_48 += $(BUILD)/.pakrun-modified

$(BUILD)/.runtime-modified: $(DEPS_48)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin"
	cp src/master-main.me $(BUILD)/bin/master-main.me
	cp src/master-start.me $(BUILD)/bin/master-start.me
	cp src/simple.me $(BUILD)/bin/simple.me
	cp src/standard.me $(BUILD)/bin/standard.me
	touch "$(BUILD)/.runtime-modified"

#
#   me
#
DEPS_49 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_HTTP),1)
    DEPS_49 += $(BUILD)/bin/libhttp.dylib
endif
ifeq ($(ME_COM_EJS),1)
    DEPS_49 += $(BUILD)/bin/libejs.dylib
endif
DEPS_49 += $(BUILD)/bin/me.mod
DEPS_49 += $(BUILD)/.runtime-modified
DEPS_49 += $(BUILD)/obj/me.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lmpr-openssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_49 += -lssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lcrypto
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_49 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_49 += -lmpr-estssl
endif
LIBS_49 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lmpr-openssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_49 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif
LIBS_49 += -lmpr
ifeq ($(ME_COM_ZLIB),1)
    LIBS_49 += -lzlib
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_49 += -lejs
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_49 += -lzlib
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_49 += -lhttp
endif

$(BUILD)/bin/me: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/me'
	$(CC) -o $(BUILD)/bin/me -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/me.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) 

#
#   testme.mod
#
DEPS_50 += src/tm/testme.es
ifeq ($(ME_COM_EJS),1)
    DEPS_50 += $(BUILD)/bin/ejs.mod
endif

$(BUILD)/bin/testme.mod: $(DEPS_50)
	( \
	cd src/tm; \
	echo '   [Compile] testme.mod' ; \
	"../../$(BUILD)/bin/ejsc" --debug --out "../../$(BUILD)/bin/testme.mod" --optimize 9 testme.es ; \
	)

#
#   testme
#
ifeq ($(ME_COM_EJS),1)
    DEPS_51 += $(BUILD)/bin/libejs.dylib
endif
DEPS_51 += $(BUILD)/bin/testme.mod
DEPS_51 += $(BUILD)/bin/ejs.testme.mod
DEPS_51 += $(BUILD)/obj/testme.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lmpr-openssl
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_51 += -lssl
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lcrypto
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_51 += -lest
endif
ifeq ($(ME_COM_EST),1)
    LIBS_51 += -lmpr-estssl
endif
LIBS_51 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lmpr-openssl
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_51 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_51 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_51 += -lpcre
endif
LIBS_51 += -lmpr
ifeq ($(ME_COM_ZLIB),1)
    LIBS_51 += -lzlib
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_51 += -lejs
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_51 += -lzlib
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_51 += -lhttp
endif

$(BUILD)/bin/testme: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/testme'
	$(CC) -o $(BUILD)/bin/testme -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/testme.o" $(LIBPATHS_51) $(LIBS_51) $(LIBS_51) $(LIBS) 

#
#   testme.es
#
DEPS_52 += src/tm/testme.es

$(BUILD)/bin/testme.es: $(DEPS_52)
	@echo '      [Copy] $(BUILD)/bin/testme.es'
	mkdir -p "$(BUILD)/bin"
	cp src/tm/testme.es $(BUILD)/bin/testme.es

#
#   installPrep
#

installPrep: $(DEPS_53)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   stop
#

stop: $(DEPS_54)

#
#   installBinary
#

installBinary: $(DEPS_55)
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "$(VERSION)" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/me $(ME_VAPP_PREFIX)/bin/me ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/me" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/me" "$(ME_BIN_PREFIX)/me" ; \
	cp $(BUILD)/bin/testme $(ME_VAPP_PREFIX)/bin/testme ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/testme" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/testme" "$(ME_BIN_PREFIX)/testme" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/ejs $(ME_VAPP_PREFIX)/bin/ejs ; \
	cp $(BUILD)/bin/ejsc $(ME_VAPP_PREFIX)/bin/ejsc ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/http $(ME_VAPP_PREFIX)/bin/http ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/http" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/http" "$(ME_BIN_PREFIX)/http" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libejs.dylib $(ME_VAPP_PREFIX)/bin/libejs.dylib ; \
	cp $(BUILD)/bin/libhttp.dylib $(ME_VAPP_PREFIX)/bin/libhttp.dylib ; \
	cp $(BUILD)/bin/libmpr.dylib $(ME_VAPP_PREFIX)/bin/libmpr.dylib ; \
	cp $(BUILD)/bin/libpcre.dylib $(ME_VAPP_PREFIX)/bin/libpcre.dylib ; \
	cp $(BUILD)/bin/libzlib.dylib $(ME_VAPP_PREFIX)/bin/libzlib.dylib ; \
	cp $(BUILD)/bin/libtestme.dylib $(ME_VAPP_PREFIX)/bin/libtestme.dylib ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libest.dylib $(ME_VAPP_PREFIX)/bin/libest.dylib ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/roots.crt $(ME_VAPP_PREFIX)/bin/roots.crt ; \
	cp $(BUILD)/bin/ejs.mod $(ME_VAPP_PREFIX)/bin/ejs.mod ; \
	cp $(BUILD)/bin/me.mod $(ME_VAPP_PREFIX)/bin/me.mod ; \
	cp $(BUILD)/bin/testme.mod $(ME_VAPP_PREFIX)/bin/testme.mod ; \
	cp $(BUILD)/bin/ejs.testme.mod $(ME_VAPP_PREFIX)/bin/ejs.testme.mod ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp src/tm/testme.h $(ME_VAPP_PREFIX)/inc/testme.h ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp src/master-main.me $(ME_VAPP_PREFIX)/bin/master-main.me ; \
	cp src/master-start.me $(ME_VAPP_PREFIX)/bin/master-start.me ; \
	cp src/simple.me $(ME_VAPP_PREFIX)/bin/simple.me ; \
	cp src/standard.me $(ME_VAPP_PREFIX)/bin/standard.me ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/paks/me-components" ; \
	cp $(BUILD)/bin/paks/me-components/appweb.me $(ME_VAPP_PREFIX)/bin/paks/me-components/appweb.me ; \
	cp $(BUILD)/bin/paks/me-components/compiler.me $(ME_VAPP_PREFIX)/bin/paks/me-components/compiler.me ; \
	cp $(BUILD)/bin/paks/me-components/components.me $(ME_VAPP_PREFIX)/bin/paks/me-components/components.me ; \
	cp $(BUILD)/bin/paks/me-components/lib.me $(ME_VAPP_PREFIX)/bin/paks/me-components/lib.me ; \
	cp $(BUILD)/bin/paks/me-components/LICENSE.md $(ME_VAPP_PREFIX)/bin/paks/me-components/LICENSE.md ; \
	cp $(BUILD)/bin/paks/me-components/link.me $(ME_VAPP_PREFIX)/bin/paks/me-components/link.me ; \
	cp $(BUILD)/bin/paks/me-components/package.json $(ME_VAPP_PREFIX)/bin/paks/me-components/package.json ; \
	cp $(BUILD)/bin/paks/me-components/rc.me $(ME_VAPP_PREFIX)/bin/paks/me-components/rc.me ; \
	cp $(BUILD)/bin/paks/me-components/README.md $(ME_VAPP_PREFIX)/bin/paks/me-components/README.md ; \
	cp $(BUILD)/bin/paks/me-components/testme.me $(ME_VAPP_PREFIX)/bin/paks/me-components/testme.me ; \
	cp $(BUILD)/bin/paks/me-components/vxworks.me $(ME_VAPP_PREFIX)/bin/paks/me-components/vxworks.me ; \
	cp $(BUILD)/bin/paks/me-components/winsdk.me $(ME_VAPP_PREFIX)/bin/paks/me-components/winsdk.me ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/paks/me-configuration" ; \
	cp $(BUILD)/bin/paks/me-configuration/Configuration.es $(ME_VAPP_PREFIX)/bin/paks/me-configuration/Configuration.es ; \
	cp $(BUILD)/bin/paks/me-configuration/configuration.me $(ME_VAPP_PREFIX)/bin/paks/me-configuration/configuration.me ; \
	cp $(BUILD)/bin/paks/me-configuration/LICENSE.md $(ME_VAPP_PREFIX)/bin/paks/me-configuration/LICENSE.md ; \
	cp $(BUILD)/bin/paks/me-configuration/package.json $(ME_VAPP_PREFIX)/bin/paks/me-configuration/package.json ; \
	cp $(BUILD)/bin/paks/me-configuration/README.md $(ME_VAPP_PREFIX)/bin/paks/me-configuration/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/paks/me-os" ; \
	cp $(BUILD)/bin/paks/me-os/freebsd.me $(ME_VAPP_PREFIX)/bin/paks/me-os/freebsd.me ; \
	cp $(BUILD)/bin/paks/me-os/gcc.me $(ME_VAPP_PREFIX)/bin/paks/me-os/gcc.me ; \
	cp $(BUILD)/bin/paks/me-os/LICENSE.md $(ME_VAPP_PREFIX)/bin/paks/me-os/LICENSE.md ; \
	cp $(BUILD)/bin/paks/me-os/linux.me $(ME_VAPP_PREFIX)/bin/paks/me-os/linux.me ; \
	cp $(BUILD)/bin/paks/me-os/macosx.me $(ME_VAPP_PREFIX)/bin/paks/me-os/macosx.me ; \
	cp $(BUILD)/bin/paks/me-os/os.me $(ME_VAPP_PREFIX)/bin/paks/me-os/os.me ; \
	cp $(BUILD)/bin/paks/me-os/package.json $(ME_VAPP_PREFIX)/bin/paks/me-os/package.json ; \
	cp $(BUILD)/bin/paks/me-os/README.md $(ME_VAPP_PREFIX)/bin/paks/me-os/README.md ; \
	cp $(BUILD)/bin/paks/me-os/solaris.me $(ME_VAPP_PREFIX)/bin/paks/me-os/solaris.me ; \
	cp $(BUILD)/bin/paks/me-os/unix.me $(ME_VAPP_PREFIX)/bin/paks/me-os/unix.me ; \
	cp $(BUILD)/bin/paks/me-os/vxworks.me $(ME_VAPP_PREFIX)/bin/paks/me-os/vxworks.me ; \
	cp $(BUILD)/bin/paks/me-os/windows.me $(ME_VAPP_PREFIX)/bin/paks/me-os/windows.me ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/paks/me-installs" ; \
	cp $(BUILD)/bin/paks/me-installs/Installs.es $(ME_VAPP_PREFIX)/bin/paks/me-installs/Installs.es ; \
	cp $(BUILD)/bin/paks/me-installs/installs.me $(ME_VAPP_PREFIX)/bin/paks/me-installs/installs.me ; \
	cp $(BUILD)/bin/paks/me-installs/LICENSE.md $(ME_VAPP_PREFIX)/bin/paks/me-installs/LICENSE.md ; \
	cp $(BUILD)/bin/paks/me-installs/manifest.me $(ME_VAPP_PREFIX)/bin/paks/me-installs/manifest.me ; \
	cp $(BUILD)/bin/paks/me-installs/package.json $(ME_VAPP_PREFIX)/bin/paks/me-installs/package.json ; \
	cp $(BUILD)/bin/paks/me-installs/README.md $(ME_VAPP_PREFIX)/bin/paks/me-installs/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/paks/me-project" ; \
	cp $(BUILD)/bin/paks/me-project/LICENSE.md $(ME_VAPP_PREFIX)/bin/paks/me-project/LICENSE.md ; \
	cp $(BUILD)/bin/paks/me-project/package.json $(ME_VAPP_PREFIX)/bin/paks/me-project/package.json ; \
	cp $(BUILD)/bin/paks/me-project/Project.es $(ME_VAPP_PREFIX)/bin/paks/me-project/Project.es ; \
	cp $(BUILD)/bin/paks/me-project/project.me $(ME_VAPP_PREFIX)/bin/paks/me-project/project.me ; \
	cp $(BUILD)/bin/paks/me-project/README.md $(ME_VAPP_PREFIX)/bin/paks/me-project/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/paks/me-vstudio" ; \
	cp $(BUILD)/bin/paks/me-vstudio/LICENSE.md $(ME_VAPP_PREFIX)/bin/paks/me-vstudio/LICENSE.md ; \
	cp $(BUILD)/bin/paks/me-vstudio/package.json $(ME_VAPP_PREFIX)/bin/paks/me-vstudio/package.json ; \
	cp $(BUILD)/bin/paks/me-vstudio/README.md $(ME_VAPP_PREFIX)/bin/paks/me-vstudio/README.md ; \
	cp $(BUILD)/bin/paks/me-vstudio/Vstudio.es $(ME_VAPP_PREFIX)/bin/paks/me-vstudio/Vstudio.es ; \
	cp $(BUILD)/bin/paks/me-vstudio/vstudio.me $(ME_VAPP_PREFIX)/bin/paks/me-vstudio/vstudio.me ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/paks/me-xcode" ; \
	cp $(BUILD)/bin/paks/me-xcode/LICENSE.md $(ME_VAPP_PREFIX)/bin/paks/me-xcode/LICENSE.md ; \
	cp $(BUILD)/bin/paks/me-xcode/package.json $(ME_VAPP_PREFIX)/bin/paks/me-xcode/package.json ; \
	cp $(BUILD)/bin/paks/me-xcode/README.md $(ME_VAPP_PREFIX)/bin/paks/me-xcode/README.md ; \
	cp $(BUILD)/bin/paks/me-xcode/Xcode.es $(ME_VAPP_PREFIX)/bin/paks/me-xcode/Xcode.es ; \
	cp $(BUILD)/bin/paks/me-xcode/xcode.me $(ME_VAPP_PREFIX)/bin/paks/me-xcode/xcode.me ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man/man1" ; \
	cp doc/dist/man/me.1 $(ME_VAPP_PREFIX)/doc/man/man1/me.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/me.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/me.1" "$(ME_MAN_PREFIX)/man1/me.1" ; \
	cp doc/dist/man/testme.1 $(ME_VAPP_PREFIX)/doc/man/man1/testme.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/testme.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man/man1/testme.1" "$(ME_MAN_PREFIX)/man1/testme.1"

#
#   start
#

start: $(DEPS_56)

#
#   install
#
DEPS_57 += installPrep
DEPS_57 += stop
DEPS_57 += installBinary
DEPS_57 += start

install: $(DEPS_57)

#
#   uninstall
#
DEPS_58 += stop

uninstall: $(DEPS_58)
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true

#
#   version
#

version: $(DEPS_59)
	echo $(VERSION)

