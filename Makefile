#######################################################################
# Build maint-guide
# vim: set ts=8:
#######################################################################
### key adjustable parameters
#######################################################################
# base file name excluding file extension
MANUAL	:=	maint-guide
# languages translated with PO files
LANGPO	:=	ca de es fr it ja ru zh-cn zh-tw vi
# languages to skip generation of PDF files
NOPDF	:=	
# languages to build document
LANGALL	=	en $(LANGPO)

VERSION := "GIT: $(shell LC_ALL=C date -u +'%F %T %Z')"

ifndef TMPDIR
TMPDIR	:= $(CURDIR)/tmp
endif

# Change $(DRAFTMODE) from "yes" to "maybe" when this document 
# should go into production mode
#DRAFTMODE      := yes
DRAFTMODE       := maybe
export DRAFTMODE
#######################################################################
### basic constant parameters
#######################################################################
# Directories (no trailing slash)
DXSL	:=	xslt
DBIN	:=	bin
DDOC	:=	doc
DPO	:=	po
DIMG	:=	/usr/share/xml/docbook/stylesheet/nwalsh/images

# Program name and option
XLINT	:=	xmllint --format
XPNO	:=	xsltproc --novalid --nonet
XPINC	:=	xsltproc --novalid --nonet --xinclude
# The threshold should be 80 if translation is completed.
THRESHOLD:=	0
TRANSLATE:=	po4a-translate  -M utf-8          --format docbook --keep $(THRESHOLD) -v 
GETTEXT	:=	po4a-gettextize -M utf-8 -L utf-8 --format docbook
UPDATEPO:=	msgmerge --update --previous
MSGATTR	:=	msgattrib
MSGCAT	:=	msgcat
DBLATEX	:=	dblatex

# English source files
DOCS	:=	$(shell ls $(DDOC)/*)
# source XML inclusion files (excluding version.ent)
ENT_STAT:=	common.ent $(addsuffix .ent, $(addprefix  $(DPO)/, $(LANGPO)))
ENT_ALL	:=	$(ENT_STAT) version.ent
# source PO files for all languages (build prcess requires these)
SRC_PO	:=	$(addsuffix .po, $(addprefix  $(DPO)/, $(LANGPO)))
# source XML files for all languages (build prcess requires these)
SRC_XML	:=	$(addsuffix .xml, $(addprefix  $(MANUAL)., $(LANGALL)))

#######################################################################
# Used as $(call check-command, <command>, <package>)
define check-command
set -e; if ! which $(1) >/dev/null; then \
  echo "Missing command: $(1), install package: $(2)"; \
  false; \
fi
endef

#######################################################################
# $ make all       # build all
#######################################################################
.PHONY: all
# set LANGPO to limit language to speed up build
all: css html txt pdf epub 

#######################################################################
# $ make test      # build html for testing (for Translator)
#######################################################################
.PHONY: test
test: html css

#######################################################################
# $ make publish   # build html text from EN.XML/PO for DDP
#######################################################################
.PHONY: package
# $(PUBLISHDIR) is set to be: /org/www.debian.org/www/doc/manuals for master-www
publish:
	-mkdir -p $(PUBLISHDIR)/$(MANUAL)
	$(MAKE) css html txt "TMPDIR=$(PUBLISHDIR)/$(MANUAL)"

#######################################################################
# $ make clean     # clean files ready for tar 
#######################################################################
.PHONY: clean
clean:
	-rm -f $(MANUAL).en.xml
	-rm -f *.swp *~ *.tmp
	-rm -f $(DPO)/*~ $(DPO)/*.mo $(DPO)/*.po.*
	-rm -rf $(TMPDIR)
	-rm -f $(addsuffix .xml, $(addprefix $(MANUAL)., $(LANGPO) en))
	-rm -f version.ent

#######################################################################
# $ make distclean # clean files to reset EN.XML/ENT/POT
#######################################################################
.PHONY: distclean
distclean: clean
	-rm -f $(DDOC)/*~
	-rm -f $(DPO)/*.pot
	-rm -f fuzzy.log

##############################################################################
# Version file preparations
##############################################################################
# version from debian/changelog
# if for www-master directly building from subversion source 
version.ent: $(DOCS)
	echo "<!ENTITY docisodate \"$(shell LC_ALL=C date -u +'%F %T %Z')\">" > version.ent
	echo "<!ENTITY docversion \"$(VERSION)\">" >> version.ent

#######################################################################
# $ make po        # update all PO from EN.XML
#######################################################################
.PHONY: po pot
pot: $(DPO)/templates.pot
po: $(SRC_PO)

# Do not record line number to avoid useless diff in po/*.po files: --no-location
# Do not update templates.pot if contents are the same as before; -I '^"POT-Creation-Date:'
$(DPO)/templates.pot: $(MANUAL).en.xml FORCE
	@$(call check-command, po4a-gettextize, po4a)
	@$(call check-command, msgcat, gettext)
	$(GETTEXT) -m $(MANUAL).en.xml | $(MSGCAT) --no-location -o $(DPO)/templates.pot.new -
	if diff -I '^"POT-Creation-Date:' -q $(DPO)/templates.pot $(DPO)/templates.pot.new ; then \
	  echo "Don't update templates.pot" ;\
	  touch $(DPO)/templates.pot ;\
	  rm -f $(DPO)/templates.pot.new ;\
	else \
	  echo "Update templates.pot" ;\
	  mv -f $(DPO)/templates.pot.new $(DPO)/templates.pot ;\
	fi
	: > fuzzy.log

# Always update
$(DPO)/%.po: $(DPO)/templates.pot FORCE
	@$(call check-command, msgmerge, gettext)
	$(UPDATEPO) $(DPO)/$*.po $(DPO)/templates.pot
	MESS1="no-obsolete  $*  `$(MSGATTR) --no-obsolete  $(DPO)/$*.po |grep ^msgid |sed 1d|wc -l`";\
	MESS2="untranslated $*  `$(MSGATTR) --untranslated $(DPO)/$*.po |grep ^msgid |sed 1d|wc -l`";\
	MESS3="fuzzy        $*  `$(MSGATTR) --fuzzy        $(DPO)/$*.po |grep ^msgid |sed 1d|wc -l`";\
	echo "$$MESS1" >>fuzzy.log ; \
	echo "$$MESS2" >>fuzzy.log ; \
	echo "$$MESS3" >>fuzzy.log ; \
	echo "" >>fuzzy.log

FORCE:

#######################################################################
# $ make wrap       # wrap all PO
#######################################################################
.PHONY: wrap nowrap wip
wrap:
	@$(call check-command, msgcat, gettext)
	for XX in $(foreach LX, $(LANGPO), $(DPO)/$(LX).po); do \
	$(MSGCAT) -o $$XX $$XX ;\
	done
nowrap:
	@$(call check-command, msgcat, gettext)
	for XX in $(foreach LX, $(LANGPO), $(DPO)/$(LX).po); do \
	$(MSGCAT) -o $$XX --no-wrap $$XX ;\
	done

wip:
	@$(call check-command, msgattrib, gettext)
	for XX in $(foreach LX, $(LANGPO), $(DPO)/$(LX).po); do \
	$(MSGATTR) -o $$XX.fuzz --fuzzy        $$XX ;\
	$(MSGATTR) -o $$XX.untr --untranslated $$XX ;\
	done

#######################################################################
# $ make xml      # update all *.xml (EN.XML ...) from DOCS /ENT/PO/ADD
#######################################################################
.PHONY: xml
xml: $(SRC_XML)

$(MANUAL).en.xml: $(DOCS)
	: > $@
	for i in $(DOCS) ; do cat $$i >> $@ ; done

$(MANUAL).%.xml: $(DPO)/%.po $(MANUAL).en.xml
	@$(call check-command, po4a-translate, po4a)
	@$(call check-command, msgcat, gettext)
	$(DBIN)/genxml $*
	sed -i -e 's/$(DPO)\/en\.ent/$(DPO)\/$*.ent/' $@

#######################################################################
# $ make css       # update CSS and DIMG in $(TMPDIR)
#######################################################################
.PHONY: css
css:
	-rm -rf $(TMPDIR)/images
	mkdir -p $(TMPDIR)/images
	cp -f $(DXSL)/debian.css $(TMPDIR)/debian.css
	echo "AddCharset UTF-8 .txt" > $(TMPDIR)/.htaccess
	cd png ; cp caution.png home.png important.png next.png note.png prev.png tip.png warning.png $(TMPDIR)/images

#######################################################################
# $ make html      # update all HTML in $(TMPDIR)
#######################################################################
.PHONY: html
html:	$(foreach LX, $(LANGALL), $(TMPDIR)/index.$(LX).html)

$(TMPDIR)/index.%.html: $(MANUAL).%.xml $(ENT_ALL)
	@$(call check-command, xsltproc, xsltproc)
	-mkdir -p $(TMPDIR)
	$(XPINC)   --stringparam base.dir $(TMPDIR)/ \
                --stringparam html.ext .$*.html \
                $(DXSL)/style-html.xsl $<

#######################################################################
# $ make txt       # update all Plain TEXT in $(TMPDIR)
#######################################################################
.PHONY: txt
txt:	$(foreach LX, $(LANGALL), $(TMPDIR)/$(MANUAL).$(LX).txt)

# txt.xsl provides work around for hidden URL links by appending them explicitly.
$(TMPDIR)/$(MANUAL).%.txt: $(MANUAL).%.xml $(ENT_ALL)
	@$(call check-command, w3m, w3m)
	@$(call check-command, xsltproc, xsltproc)
	-mkdir -p $(TMPDIR)
	@test -n "`which w3m`"  || { echo "ERROR: w3m not found. Please install the w3m package." ; false ;  }
	$(XPINC) $(DXSL)/style-txt.xsl $< | \
	  LC_ALL=en_US.UTF-8 w3m -o display_charset=UTF-8 -cols 70 -dump -no-graph -T text/html > $@


#######################################################################
# $ make pdf       # update all PDF in $(TMPDIR)
#######################################################################
.PHONY: pdf
pdf:	$(foreach LX, $(LANGALL), $(TMPDIR)/$(MANUAL).$(LX).pdf)

$(foreach LX, $(NOPDF), $(TMPDIR)/$(MANUAL).$(LX).pdf):
	-mkdir -p $(TMPDIR)
	echo "PDF generation skipped." >$@

# dblatex.xsl provide work around for hidden URL links by appending them explicitly.
$(TMPDIR)/$(MANUAL).%.pdf: $(MANUAL).%.xml $(ENT_ALL)
	@$(call check-command, dblatex, dblatex)
	@$(call check-command, xsltproc, xsltproc)
	-mkdir -p $(TMPDIR)/pdf-$*
	@test -n "`which $(DBLATEX)`"  || { echo "ERROR: dblatex not found. Please install the dblatex package." ; false ;  }
	export TEXINPUTS=".:"; \
	export TMPDIR="$(TMPDIR)/pdf-$*"; \
	$(XPINC) $(DXSL)/dblatex.xsl $<  | \
	$(DBLATEX) --style=native \
		--debug \
		--backend=xetex \
		--xsl-user=$(DXSL)/user_param.xsl \
		--xsl-user=$(DXSL)/xetex_param.xsl \
		--param=draft.mode=$(DRAFTMODE) \
		--param=lingua=$* \
		--output=$@ - || { echo "OMG!!!!!! XXX_CHECK_XXX ... Do not worry ..."; true ; }

#######################################################################
# $ make tex       # update all TeX source in $(TMPDIR)
#######################################################################
.PHONY: tex
tex:	$(foreach LX, $(LANGALL), $(TMPDIR)/$(MANUAL).$(LX).tex)

# dblatex.xsl provide work around for hidden URL links by appending them explicitly.
$(TMPDIR)/$(MANUAL).%.tex: $(MANUAL).%.xml $(ENT_ALL)
	-mkdir -p $(TMPDIR)/tex-$*
	@test -n "`which $(DBLATEX)`"  || { echo "ERROR: dblatex not found. Please install the dblatex package." ; false ;  }
	export TEXINPUTS=".:"; \
	export TMPDIR="$(TMPDIR)/tex-$*"; \
	$(XPINC) $(DXSL)/dblatex.xsl $<  | \
	$(DBLATEX) --style=native \
		--debug \
		--type=tex \
		--backend=xetex \
		--xsl-user=$(DXSL)/user_param.xsl \
		--xsl-user=$(DXSL)/xetex_param.xsl \
		--param=draft.mode=$(DRAFTMODE) \
		--param=lingua=$* \
		--output=$@ - || { echo "OMG!!!!!! XXX_CHECK_XXX ... Do not worry ..."; true ; }

#######################################################################
# $ make epub      # update all epub in $(TMPDIR)
#######################################################################
.PHONY: epub
epub:	$(foreach LX, $(LANGALL), $(TMPDIR)/$(MANUAL).$(LX).epub)

$(TMPDIR)/$(MANUAL).%.epub: $(MANUAL).%.xml $(ENT_ALL)
	@$(call check-command, xsltproc, xsltproc)
	-mkdir -p $(TMPDIR)/epub-$*/
	cd $(TMPDIR)/epub-$*/ ; $(XPINC) $(CURDIR)/$(DXSL)/style-epub.xsl $(CURDIR)/$<
	cp -f $(DXSL)/mimetype $(TMPDIR)/epub-$*/mimetype
	cp -f $(DXSL)/debian.css $(TMPDIR)/epub-$*/OEBPS/debian.css
	cp -f $(DXSL)/debian-openlogo.png $(TMPDIR)/epub-$*/OEBPS/debian-openlogo.png
	cd $(TMPDIR)/epub-$*/ ; zip -r $@ ./

#######################################################################
### Utility targets
#######################################################################
#######################################################################
# $ make rsync     
# export build result to http://people.debian.org/~osamu/$(MANUAL)/
#######################################################################
.PHONY: rsync
rsync: all
	-rm -rf $(TMPDIR)/pdf-*
	-rm -rf $(TMPDIR)/tex-*
	-rm -rf $(TMPDIR)/epub-*
	cp -f fuzzy.log $(TMPDIR)/
	rsync -avz $(TMPDIR)/ osamu@people.debian.org:public_html/$(MANUAL)/

#######################################################################
# $ make url       # check duplicate URL references
#######################################################################
.PHONY: url
url: $(MANUAL).en.xml
	@echo "----- Duplicate URL references (start) -----"
	-sed -ne "/^<\!ENTITY/s/<\!ENTITY \([^ ]*\) .*$$/\" \1 \"/p"  < $< | uniq -d | xargs -n 1 grep $< -e  | grep -e "^<\!ENTITY"
	@echo "----- Duplicate URL references (end) -----"

