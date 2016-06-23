#!/usr/bin/env python3

import os
import os.path
import subprocess
import sys
import urllib.request


################################################################################
################################################################################
class GitignoreTemplatesPopulator():
    '''Holds functionality to install and update the gitignore templates.'''

    gitignore_template_sources = [
            'https://github.com/github/gitignore.git',
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
    def _get_templates_name_from_source(self, source):
        '''Extracts template name from source URL.
        Requires that every URL is */TEMPLATES_NAME.git
        '''

        if not source.endswith('.git'):
            print('Cannot extract templates name from source {}'.format(source))
            return None

        file_name = source.strip().split('/')[-1]
        templates_name = file_name[0:-4]

        return templates_name


################################################################################
    def _set_environment(self):
        '''Set environment e.g. based on OS.'''

        # only supported on linux
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
            self.gitignore_templates_dir = os.path.join(self.home_dir, '.gitignore_templates')
            print('gitignore_templates dir is {}: '.format(self.gitignore_templates_dir))
        elif self.platform is 'win':
            self.home_dir = 'w:'
            self.gitignore_templates_dir = os.path.join(self.home_dir, '_gitignore_templates')
            print('gitignore_templates dir is {}: '.format(self.gitignore_templates_dir))

        print()


################################################################################
    def _make_dirs(self):
        '''Makes directoriy needed for templates (if not exist).'''

        if not os.path.exists(self.gitignore_templates_dir):
            os.makedirs(self.gitignore_templates_dir)


################################################################################
    def _install_templates(self, name, source):
        '''Get the gitignore templates.'''

        print('Installing {}...'.format(name))

        if os.path.exists(os.path.join(self.gitignore_templates_dir, name)):
            print('Already installed.'.format(name))
            print()
            return True

        subprocess.call(['git', 'clone', source, os.path.join(self.gitignore_templates_dir, name)])

        print()


################################################################################
    def install(self):
        '''Install templates (if not installed yet).'''

        self._make_dirs()

        for source in self.gitignore_template_sources:
            name = self._get_templates_name_from_source(source)
            if name is None:
                continue
            self._install_templates(name, source)


################################################################################
    def _update_templates(self, name):
        '''Updates templates with git pull.'''

        print('Updating {}: '.format(name))

        templates_dir = os.path.join(self.gitignore_templates_dir, name)

        if not os.path.isdir(templates_dir):
            print('{} not yet installed. Skipping...'.format(name))

        os.chdir(templates_dir)
        subprocess.call(['git', 'pull'])

        print()


################################################################################
    def update(self):
        '''Update templates.'''

        # update templates using git
        for source in self.gitignore_template_sources:
            name = self._get_templates_name_from_source(source)
            if name is None:
                continue
            self._update_templates(name)



################################################################################
################################################################################
if __name__ == '__main__':
    populator = GitignoreTemplatesPopulator()
