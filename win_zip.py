#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2020, Kani Eren <kanieren@gmail.com>
#
# This file is not part of Ansible
#
# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = r'''
---
module: win_zip
version_added: "2.7"
short_description: zips files and archives on the Windows node
description:
- zips files and directories.
- Supports .zip files natively
- For non-Windows targets, use the M(archive) module instead.
requirements:
options:
  src:
    description:
      - File to be zipped (provide absolute path).
    required: true
  dest:
    description:
      - Destination of zip file as directory. 
    required: true
  filename:
    description:
      - Absolute name of zip file (provide absolute name and extension). 
    required: true
  days:
    description:
      - Processes files older than the days before.
    required: false
notes:
- This module is not really idempotent, it will create the archive every time, and report a change.
- For non-Windows targets, use the M(archive) module instead.
author:
- Kani Eren 
'''

EXAMPLES = r'''

- name: zip a directory
  win_zip:
    src: C:\Users\Someuser\Logs
    dest: C:\Users\Someuser
	filename: OldLogs.zip
    days: 10

'''

RETURN = r'''
dest:
    description: The provided destination path
    returned: always
    type: string
    sample: C:\Users\Someuser\OldLogs.zip
src:
    description: The provided source path
    returned: always
    type: string
    sample: C:\Logs\logsToZip\
olderthan:
    description: Older than parameter
    returned: ifDefined
    type: int
    sample: 10
'''
