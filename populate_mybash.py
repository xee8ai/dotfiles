#!/usr/bin/env python3

import os
import os.path
import subprocess
import sys
import urllib.request


################################################################################
################################################################################
class MyBashPopulator():
    '''Holds functionality to install and update plugins for console(s).'''

    plugin_sources = [
            'https://github.com/joepvd/tty-solarized.git',
            'https://github.com/nojhan/liquidprompt.git',
    ]



################################################################################
    def __init__(self):
        '''Constructor.'''

        self._define_tasks()
        self._check_args()
        self._set_environment()

        # run selected task
        self.tasks[self.task]()


################################################################################
    def _define_tasks(self):
        '''Define possible tasks and methods to call.'''

        self.tasks = {
                'install': self.install,
                'update': self.update,
        }


################################################################################
    def _check_args(self):
        '''Check given CLI.'''

        def error_func():
            print('Usage: {} [{}]'.format(sys.argv[0], '|'.join(self.tasks)))
            sys.exit(1)

        if len(sys.argv) != 2:
            error_func()

        if sys.argv[1] not in self.tasks:
            error_func()

        self.task = sys.argv[1]


################################################################################
    def _get_plugin_name_from_source(self, source):
        '''Extracts plugin name from source URL.
        Requires that every URL is */PLUGIN_NAME.git
        '''

        if not source.endswith('.git'):
            print('Cannot extract plugin name from source {}'.format(source))
            return None

        file_name = source.strip().split('/')[-1]
        plugin_name = file_name[0:-4]

        return plugin_name


################################################################################
    def _set_environment(self):
        '''Set environment e.g. based on OS.'''

        # only supported on linux
        if sys.platform.startswith('linux'):
            self.platform = 'linux'
        else:
            print('ERROR: Unknown operating system ({})'.format(sys.platform))
            sys.exit(1)

        print('Used operating system is: {}'.format(self.platform))

        if self.platform is 'linux':
            # set environment generic
            self.home_dir = os.getenv('HOME')
            self.mybash_dir = os.path.join(self.home_dir, '.mybash')
            print('mybash dir is {}: '.format(self.mybash_dir))

        print()


################################################################################
    def _make_dirs(self):
        '''Makes directoriy needed for plugins (if not exist).'''

        if not os.path.exists(self.mybash_dir):
            os.makedirs(self.mybash_dir)


################################################################################
    def _install_plugin(self, name, source):
        '''Installes a given plugin (if not yet installed).'''

        print('Installing {}...'.format(name))

        if os.path.exists(os.path.join(self.mybash_dir, name)):
            print('Already installed.'.format(name))
            print()
            return True

        subprocess.call(['git', 'clone', source, os.path.join(self.mybash_dir, name)])

        print()


################################################################################
    def install(self):
        '''Install plugins (if not installed yet).'''

        self._make_dirs()

        for source in self.plugin_sources:
            name = self._get_plugin_name_from_source(source)
            if name is None:
                continue
            self._install_plugin(name, source)


################################################################################
    def _update_plugin(self, name):
        '''Updates a plugin with git pull.'''

        print('Updating {}: '.format(name))

        plugin_dir = os.path.join(self.mybash_dir, name)

        if not os.path.isdir(plugin_dir):
            print('{} not yet installed. Skipping...'.format(name))

        os.chdir(plugin_dir)
        subprocess.call(['git', 'pull'])

        print()


################################################################################
    def update(self):
        '''Update plugins.'''

        # update plugins using git
        for source in self.plugin_sources:
            name = self._get_plugin_name_from_source(source)
            if name is None:
                continue
            self._update_plugin(name)



################################################################################
################################################################################
if __name__ == '__main__':
    populator = MyBashPopulator()
