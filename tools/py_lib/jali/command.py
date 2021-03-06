# Copyright (c) 2017, Los Alamos National Security, LLC
# All rights reserved.

# Copyright 2017. Los Alamos National Security, LLC. This software was
# produced under U.S. Government contract DE-AC52-06NA25396 for Los
# Alamos National Laboratory (LANL), which is operated by Los Alamos
# National Security, LLC for the U.S. Department of Energy. The
# U.S. Government has rights to use, reproduce, and distribute this
# software.  NEITHER THE GOVERNMENT NOR LOS ALAMOS NATIONAL SECURITY,
# LLC MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LIABILITY
# FOR THE USE OF THIS SOFTWARE.  If software is modified to produce
# derivative works, such modified software should be clearly marked, so
# as not to confuse it with the version available from LANL.
 
# Additionally, redistribution and use in source and binary forms, with
# or without modification, are permitted provided that the following
# conditions are met:

# 1.  Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3.  Neither the name of Los Alamos National Security, LLC, Los Alamos
# National Laboratory, LANL, the U.S. Government, nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
 
# THIS SOFTWARE IS PROVIDED BY LOS ALAMOS NATIONAL SECURITY, LLC AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL LOS
# ALAMOS NATIONAL SECURITY, LLC OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
# GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


################################################################################

import os, sys
import shlex

################################################################################

class CommandInterface:
    
    def __init__(self,command,args=None):
        
        self.command = command
        self.args = []
        self.exit_code=0
        self.output=''

        if args != None:
            self._parse_arg_list(args)

        try:
            import subprocess
            self.use_ospipe = False
	except ImportError:
            self.use_ospipe = True
	except:
	    print "Unexpected error:",sys.exec_info()[0]
	    raise
	    

    def _dump_state(self):
        print 'command=',self.command
        print 'args=',self.args
        print 'exit_code=',self.exit_code
        print 'output=',self.output
        print 'use_ospipe=',self.use_ospipe

    def _parse_arg_list(self,args):
        list_args=[]
        if isinstance(args,list):
            list_args = shlex.split(" ".join(args))
        elif isinstance(args,str):
            list_args = shlex.split(args)
        else:
            raise TypeError, 'args must be of type list or str'
        self.args = list_args 
        return list_args

    def _build_run_command(self):
        string=' '.join(self.args)
        return self.command + ' ' + ' '.join(self.args)

    def _parse_shell_exit(self,pattern):
        m = pattern.findall(self.output)
        if m != None:
            idx = len(m) - 1
            self.exit_code = m[idx]

        return self.exit_code    

    def _remove_shell_exit(self,pattern):
        self.output = pattern.sub('',self.output)
       
    def set_args(self,args):
        self.args = self._parse_arg_list(args)
        return self.args

    def add_args(self,args):
        if len(self.args) == 0:
	  self.set_args(args)
	else:  
          new_args = self._parse_arg_list(args)
	  self.args.append(new_args)
        return self.args

    def search_args(self,target,index=None):
        index = -1
        if target in self.args:
            index = self.args.index(target)

        return index

    def clear_args(self):
        self.args = []
        return 

    def run(self):
        if self.use_ospipe == True:
            self._ospipe_run()
        else:
            self._subprocess_run()

        return self.exit_code    
    
    def _subprocess_run(self):

        import subprocess
        from subprocess import Popen,PIPE,STDOUT
	import time
	import signal

        run_command=self._build_run_command()
	try:
          pipe = Popen(run_command,shell=True,stdout=PIPE,stderr=STDOUT)
	except ValueError:
	  raise ValueError, 'Incorrect arguments in Popen'
	except:
	  raise
	else:
	  output=pipe.stdout
	  self.ouput=output.read()
	  output.close

        # Do not leave until the process completes!
        while pipe.poll() == None:
	  pass

        # Set the return code
        self.exit_code=pipe.returncode 
        
        # Dump out the output
	print self.output

        return self.exit_code

    def _ospipe_run(self):
        import os
        import re
        run_command = self._build_run_command()

        # Need the '$' to delete the last print just
        # in case the command output also has this 
        # print out!
        pattern = re.compile('SHELL_EXIT=(\d+)$')
        
        run_command = run_command + '; echo SHELL_EXIT=$?'
        (child_stdin, child_outerr) =os.popen4(run_command)
        child_stdin.close()
        self.output = child_outerr.read()
        self.exit_code = child_outerr.close()
        if self.exit_code == None:
            self._parse_shell_exit(pattern)
        self._remove_shell_exit(pattern)    
            

        return self.exit_code

################################################################################

def Command(command,args=None):
    cmd = CommandInterface(command,args)
    cmd.run()
    
    return cmd

################################################################################
if __name__ == '__main__':

    command='ls'
    ci=CommandInterface(command)
    ci.set_args('-lat')
    ci._dump_state()

    args=['-l', '-a']
    cmd = Command(command,args=args)
    cmd._dump_state()

    yacmd = Command('which','h5diff')

    bad_cmd=Command('dummy_exe')
    bad_cmd._dump_state()

