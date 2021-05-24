#=============================================================================#
# Copyright 2020 Matthew D. Steele <mdsteele@alum.mit.edu>                    #
#                                                                             #
# This file is part of Big2Small.                                             #
#                                                                             #
# Big2Small is free software: you can redistribute it and/or modify it under  #
# the terms of the GNU General Public License as published by the Free        #
# Software Foundation, either version 3 of the License, or (at your option)   #
# any later version.                                                          #
#                                                                             #
# Big2Small is distributed in the hope that it will be useful, but WITHOUT    #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or       #
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for   #
# more details.                                                               #
#                                                                             #
# You should have received a copy of the GNU General Public License along     #
# with Big2Small.  If not, see <http://www.gnu.org/licenses/>.                #
#=============================================================================#

SRCDIR = src
OUTDIR = out
BINDIR = $(OUTDIR)/bin
DATADIR = $(OUTDIR)/data
GENDIR = $(OUTDIR)/gen
OBJDIR = $(OUTDIR)/obj
ROMFILE = $(OUTDIR)/big2small.gb
SYMFILE = $(OUTDIR)/big2small.sym
AHI22BPP = $(BINDIR)/ahi22bpp
BG2MAP = $(BINDIR)/bg2map
SNG2ASM = $(BINDIR)/sng2asm

AHIFILES := $(shell find $(SRCDIR) -name '*.ahi')
ASMFILES := $(shell find $(SRCDIR) -name '*.asm')
BGFILES := $(shell find $(SRCDIR) -name '*.bg')
INCFILES := $(shell find $(SRCDIR) -name '*.inc')
SNGFILES := $(shell find $(SRCDIR) -name '*.sng')

BPPFILES := $(patsubst $(SRCDIR)/%.ahi,$(DATADIR)/%.2bpp,$(AHIFILES))
GENFILES := $(patsubst $(SRCDIR)/%.sng,$(GENDIR)/%.asm,$(SNGFILES))
MAPFILES := $(patsubst $(SRCDIR)/%.bg,$(DATADIR)/%.map,$(BGFILES))
OBJFILES := $(patsubst $(SRCDIR)/%.asm,$(OBJDIR)/%.o,$(ASMFILES)) \
            $(patsubst $(GENDIR)/%.asm,$(GENDIR)/%.o,$(GENFILES))

#=============================================================================#

.PHONY: rom
rom: $(ROMFILE)

.PHONY: run
run: $(ROMFILE)
	open -a SameBoy $<

.PHONY: test
test:
	python tests/solutions.py

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

#=============================================================================#

define compile-c99
	@echo "Compiling $<"
	@mkdir -p $(@D)
	@cc -Wall -o $@ $<
endef

$(AHI22BPP): build/ahi22bpp.c
	$(compile-c99)

$(DATADIR)/%.2bpp: $(SRCDIR)/%.ahi $(AHI22BPP)
	@echo "Converting $<"
	@mkdir -p $(@D)
	@$(AHI22BPP) < $< > $@

$(BG2MAP): build/bg2map.c
	$(compile-c99)

$(DATADIR)/%.map: $(SRCDIR)/%.bg $(BG2MAP)
	@echo "Converting $<"
	@mkdir -p $(@D)
	@$(BG2MAP) < $< > $@

$(SNG2ASM): build/sng2asm.c
	$(compile-c99)

$(GENDIR)/%.asm: $(SRCDIR)/%.sng $(SNG2ASM)
	@echo "Converting $<"
	@mkdir -p $(@D)
	@$(SNG2ASM) < $< > $@

.SECONDARY: $(GENFILES)

#=============================================================================#

$(ROMFILE): $(OBJFILES)
	@echo "Linking $@"
	@mkdir -p $(@D)
	@rgblink --dmg --sym $(SYMFILE) -o $@ $^
	@echo "Fixing $@"
	@rgbfix -v -p 0 $@

define compile-asm
	@echo "Compiling $<"
	@mkdir -p $(@D)
	@rgbasm -Wall -Werror -o $@ $<
endef

$(OBJDIR)/mapdata.o: $(SRCDIR)/mapdata.asm $(INCFILES) $(MAPFILES)
	$(compile-asm)

$(OBJDIR)/tiledata.o: $(SRCDIR)/tiledata.asm $(INCFILES) $(BPPFILES)
	$(compile-asm)

$(OBJDIR)/%.o: $(SRCDIR)/%.asm $(INCFILES)
	$(compile-asm)

$(GENDIR)/%.o: $(GENDIR)/%.asm
	$(compile-asm)

#=============================================================================#
