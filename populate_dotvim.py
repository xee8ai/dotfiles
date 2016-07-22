#!/usr/bin/env python3

import os
import os.path
import shutil
import subprocess
import sys
import urllib.request


################################################################################
################################################################################
class DotvimPopulator():
    '''Holds functionality to install and update vim plugins.'''

    # this list holds the (git) URL from where to download the plugins
    plugin_sources = [
            'https://github.com/mattn/emmet-vim.git',
            'https://github.com/scrooloose/nerdtree.git',
            'git://github.com/altercation/vim-colors-solarized.git',
            'https://github.com/scrooloose/syntastic.git',
            'https://github.com/jistr/vim-nerdtree-tabs.git',
            'https://github.com/tpope/vim-surround.git',
            'https://github.com/tpope/vim-commentary.git',
            'git://github.com/xsbeats/vim-blade.git',
            'git://github.com/majutsushi/tagbar.git',
            'https://github.com/ludovicchabant/vim-gutentags.git',
            'https://github.com/tpope/vim-repeat.git',
            # 'https://github.com/svermeulen/vim-easyclip.git',
    ]

    # if a plugin is not used anymore: add relative dirname here to delete the plugin on all systems
    plugin_delete_dirs = [
            'AutoTag',  # switched to vim-gutentags instead
    ]

    # this is only a dummy list to hold sources that are not used ATM
    # use this as a reference to old times (e.g. if a plugin is needed again)
    plugin_sources_obsolete = [
            'https://github.com/vim-scripts/AutoTag.git',
    ]



################################################################################
    def __init__(self):
        '''Constructor.'''

        self._define_tasks()
        self._check_args()
        self._set_environment()

        self._delete_plugins()

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

        if sys.platform.startswith('linux'):
            self.platform = 'linux'
        elif sys.platform.startswith('win'):
            self.platform = 'win'
        else:
            print('ERROR: Unknown operating system ({})'.format(sys.platform))
            sys.exit(1)

        print('Used operating system is: {}'.format(self.platform))

        if self.platform is 'linux':
            # set environment generic
            self.home_dir = os.getenv('HOME')
            self.vim_dir = os.path.join(self.home_dir, '.vim')
            print('vim dir is {}: '.format(self.vim_dir))
        elif self.platform is 'win':
            # set hardcoded (as there is only one Windows I have to use :-))
            self.vim_dir = 'w:\\vimfiles'
            print('vim dir is {}: '.format(self.vim_dir))

            # copy vimrc (for symlinks in win you need administrative rights)
            print('Copying .vimrc...')
            shutil.copy('w:\\dotfiles\\.vimrc', 'w:\\_vimrc')

        self.bundle_dir = os.path.join(self.vim_dir, 'bundle')

        print()


################################################################################
    def _make_dirs(self):
        '''Makes directories needed for vim plugins (if not exist).'''

        sub_dirs = ['autoload', 'bundle']

        for sub_dir in sub_dirs:
            dir_name = os.path.join(self.vim_dir, sub_dir)
            if not os.path.exists(dir_name):
                os.makedirs(dir_name)


################################################################################
    def _install_pathogen(self):
        '''Installes pathogen (use also for updating).'''

        print('(Re)Installing pathogen...')

        with urllib.request.urlopen('https://tpo.pe/pathogen.vim') as response, open(os.path.join(self.vim_dir, 'autoload', 'pathogen.vim'), 'wb') as out_file:
            data = response.read() # a byte object
            out_file.write(data)

        print()


################################################################################
    def _install_plugin(self, name, source):
        '''Installes a given plugin (if not yet installed).'''

        print('Installing {}...'.format(name))

        if os.path.exists(os.path.join(self.bundle_dir, name)):
            print('Already installed.'.format(name))
            print()
            return True

        subprocess.call(['git', 'clone', source, os.path.join(self.bundle_dir, name)])

        print()


################################################################################
    def _delete_plugins(self):

        print('Checking for plugins to delete...')

        for del_plugin in self.plugin_delete_dirs:

            full_path = os.path.join(self.bundle_dir, del_plugin)

            if os.path.isdir(full_path):
                shutil.rmtree(full_path)
                print('{} deleted'.format(del_plugin))

        print()


################################################################################
    def install(self):
        '''Install plugins (if not installed yet).'''

        self._make_dirs()

        self._install_pathogen()

        for source in self.plugin_sources:
            name = self._get_plugin_name_from_source(source)
            if name is None:
                continue
            self._install_plugin(name, source)


################################################################################
    def _update_plugin(self, name):
        '''Updates a plugin with git pull.'''

        print('Updating {}: '.format(name))

        plugin_dir = os.path.join(self.bundle_dir, name)

        if not os.path.isdir(plugin_dir):
            print('{} not yet installed. Skipping...'.format(name))

        os.chdir(plugin_dir)
        subprocess.call(['git', 'pull'])

        print()


################################################################################
    def update(self):
        '''Update plugins.'''

        # just re-install
        self._install_pathogen()

        # update plugins using git
        for source in self.plugin_sources:
            name = self._get_plugin_name_from_source(source)
            if name is None:
                continue
            self._update_plugin(name)



################################################################################
################################################################################
if __name__ == '__main__':
    populator = DotvimPopulator()
