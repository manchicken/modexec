# ModExec.pm -- An abstraction layer providing more direct execution of Perl modules
# Copyright (C) 2006-2014  Michael D. Stemle, Jr.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use 5.008008;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'ModExec',
    VERSION_FROM      => 'lib/ModExec.pm', # finds $VERSION
    PREREQ_PM         => {JSON=>1.07, URI::Escape=>3.28}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/ModExec.pm', # retrieve abstract from module
       AUTHOR         => 'Michael D. Stemle <manchicken@notsosoft.net>') : ()),
);
