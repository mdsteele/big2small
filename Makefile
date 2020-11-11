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
OBJDIR = $(OUTDIR)/obj
ROMFILE = $(OUTDIR)/big2small.gb
SYMFILE = $(OUTDIR)/big2small.sym
AHI_TO_2BPP = $(BINDIR)/ahi_to_2bpp

AHIFILES := $(shell find $(SRCDIR) -name '*.ahi')
ASMFILES := $(shell find $(SRCDIR) -name '*.asm')
BPPFILES := $(patsubst $(SRCDIR)/%.ahi,$(DATADIR)/%.2bpp,$(AHIFILES))
INCFILES := $(shell find $(SRCDIR) -name '*.inc')
OBJFILES := $(patsubst $(SRCDIR)/%.asm,$(OBJDIR)/%.o,$(ASMFILES))

#=============================================================================#

.PHONY: rom
rom: $(ROMFILE)

.PHONY: run
run: $(ROMFILE)
	open -a SameBoy $<

.PHONY: clean
clean:
	rm -rf $(OUTDIR)

#=============================================================================#

$(AHI_TO_2BPP): build/ahi_to_2bpp.c
	@mkdir -p $(@D)
	cc -o $@ $<

$(DATADIR)/%.2bpp: $(SRCDIR)/%.ahi $(AHI_TO_2BPP)
	@mkdir -p $(@D)
	$(AHI_TO_2BPP) < $< > $@

#=============================================================================#

$(ROMFILE): $(OBJFILES)
	@mkdir -p $(@D)
	rgblink --dmg --sym $(SYMFILE) -o $@ $^
	rgbfix -v -p 0 $@

define compile-asm
	@mkdir -p $(@D)
	rgbasm -Wall -Werror -o $@ $<
endef

$(OBJDIR)/tiles.o: $(SRCDIR)/tiles.asm $(BPPFILES)
	$(compile-asm)

$(OBJDIR)/%.o: $(SRCDIR)/%.asm $(INCFILES)
	$(compile-asm)

#=============================================================================#
