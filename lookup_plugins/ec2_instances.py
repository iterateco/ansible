from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import boto
import json
import pprint

try:
    from __main__ import display
except ImportError:
    from ansible.utils.display import Display
    display = Display()

from ansible.errors import AnsibleError

class LookupModule(object):

    def __init__(self, basedir=None, **kwargs):
        self.basedir = basedir
        self._display = display

    def run(self, vars=None, **kwargs):

        conn = boto.connect_ec2()
	  
        reservations = conn.get_all_instances()
        hosts = []
        for reservation in reservations:
            for instance in reservation.instances:
                # host = instance.__dict__
                host = {'tags': instance.tags, 'private_ip_address': instance.private_ip_address, 'ip_address': instance.private_ip_address}
                hosts.append(host)

        # can not return list https://github.com/ansible/ansible/issues/10291
        return [json.dumps(hosts)]