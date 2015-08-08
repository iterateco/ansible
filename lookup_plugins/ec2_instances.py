from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import boto
import json

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

from ansible.errors import AnsibleError
# from ansible.plugins.lookup import LookupBase
# print ansible.plugins.lookup

class LookupModule(object):

    def __init__(self, basedir=None, **kwargs):
        self.basedir = basedir
        self._display = display

    def run(self, vars=None, **kwargs):

        conn = boto.connect_ec2()
	    # entries = []
        reservations = conn.get_all_instances()
        hosts = []
        for reservation in reservations:
            for instance in reservation.instances:
                #host = instance.__dict__
                host = {'tags': instance.tags, 'private_ip_address': instance.private_ip_address}
                hosts.append(host)

        self._display(hosts)
        # can not return list https://github.com/ansible/ansible/issues/10291
        return [json.dumps(hosts)]