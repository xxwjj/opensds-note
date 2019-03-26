# heat-orchestration-opensds-resources #

### 相关命令
* 查询resource type

		openstack orchestration resource type list
		openstack orchestration resource type show OS::Cinder::Volume

* 增删查

		openstack stack create -t create-volume.yml --parameter "size=1" stack001
		openstack stack delete stack001
		openstack stack show stack001
		openstack stack list

*  查询输出

		openstack stack output list stack001
		openstack stack output show stack001 instance_name

### OpenSDS HOT

	heat_template_version: 2015-10-15
	description: Create a Volume with policy from OpenSDS.
	
	parameters:
	  size:
	    type: string
	    description: Size of volume
	
	resources:
	  volume:
	    type: OS::OpenSDS::Volume
	    properties:
	      name: heat-opensds-vol001
	      size:  { get_param: size} 
	      description: "Opensds heat test volume" 
	      profile_id: e04cd76c-1fae-4680-a4c2-bbd32593b292
	
	outputs:
	  volume_name:
	    description: Show of the volume.
	    value: { get_attr: [ volume, name ] }

### Cinder HOT
	heat_template_version: 2015-10-15
	description: Launch a basic instance with CirrOS image using the
	             ``m1.tiny`` flavor, ``mykey`` key,  and one network.
	
	parameters:
	  size:
	    type: string
	    description: Network ID to use for the instance.
	
	resources:
	  server:
	    type: OS::Cinder::Volume
	    properties:
	      name: heatvol001
	      size:  { get_param: size} 
	
	outputs:
	  instance_name:
	    description: Show of the volume.
	    value: { get_attr: [ server, show ] }


### code

``` python
try:
    import httplib
except ImportError: # pragma: no cover
    import http.client as httplib
import json
from heat.engine import attributes
from heat.engine import properties
from heat.engine import resource
from heat.common.i18n import _
from oslo_log import log as logging


LOG = logging.getLogger(__name__)


class OsdsVolume(resource.Resource):
    HOST = '182.138.104.147:50040'
    PROPERTIES = (
        NAME, SIZE, DESCRIPTION, PROFILE_ID
    ) = (
        'name', 'size', 'description', 'profile_id',
    )

    ATTRIBUTES = (
        NAME_ATTR, SIZE_ATTR, DESCRIPTION_ATTR, PROFILE_ID_ATTR
    ) = (
        'name', 'size', 'description', 'profile_id',
    )

    properties_schema = {
        NAME: properties.Schema(
            properties.Schema.STRING,
            _('Name of the OpenSDS volume.')
        ),
        SIZE: properties.Schema(
            properties.Schema.STRING,
            _('Size of the OpenSDS volume.')
        ),
        DESCRIPTION: properties.Schema(
            properties.Schema.STRING,
            _('Source of the OpenSDS volume.')
        ),
        PROFILE_ID: properties.Schema(
            properties.Schema.STRING,
            _('Profile ID of the OpenSDS volume.')
        ),
    }
    attributes_schema = {

        NAME_ATTR: attributes.Schema(
            _('Name of the OpenSDS volume.'),
            type=attributes.Schema.STRING
        ),
        SIZE_ATTR: attributes.Schema(
            _('The size of the OpenSDS volume in GB.'),
            type=attributes.Schema.STRING
        ),
        DESCRIPTION_ATTR: attributes.Schema(
            _('The descrition of the OpenSDS volume.'),
            type=attributes.Schema.STRING
        ),
        PROFILE_ID_ATTR: attributes.Schema(
            _('The Profile Id of the OpenSDS volume.'),
            type=attributes.Schema.STRING
        ),
    }

    def handle_create(self):
        LOG.info(self.properties.get(self.NAME))
        LOG.info(self.properties.get(self.DESCRIPTION))
        LOG.info(self.properties.get(self.SIZE))
        LOG.info(self.properties.get(self.PROFILE_ID))
        volume = self._create_volume(self.properties.get(self.NAME), self.properties.get(self.DESCRIPTION),
                                        self.properties.get(self.SIZE), self.properties.get(self.PROFILE_ID))
        volume_id = volume["id"]
        self.resource_id_set(volume_id)
        return volume_id

    def handle_delete(self):
        if self.resource_id  is None:
            return
        volume = self._get_volume(self.resource_id)
        self._delete_volume(self.resource_id, volume["profileId"])

    def _resolve_attribute(self, name):
        LOG.info(self.properties.get(self.NAME))
        LOG.info(self.properties.get(self.DESCRIPTION))
        LOG.info(self.properties.get(self.SIZE))
        LOG.info(self.properties.get(self.PROFILE_ID))
        if name == self.NAME:
            return self.properties.get(self.NAME)

    def _create_volume(self, name, description, size, profile_id):
        data = {
            "name": name,
            "description": description,
            "size": int(size),
            "profileId": profile_id
        }
        headers = {"Content-type": "application/json"}
        conn = None
        try:
            conn = httplib.HTTPConnection(self.HOST)
            conn.request('POST', '/api/v1alpha/block/volumes', json.dumps(data), headers)
            resp = conn.getresponse()
            body = resp.read()
        finally:
            if conn:
                conn.close()
        LOG.info("status:%s, reason:%s, response:%s" % (resp.status, resp.reason, body))
        if resp.status not in [200, 201, 202]:
            raise Exception(body)
        return json.loads(bytes.decode(body))

    def _delete_volume(self, volume_id, profile_id):
        data = {
            "profileId": profile_id
        }
        headers = {"Content-type": "application/json"}
        conn = None
        try:
            conn = httplib.HTTPConnection(self.HOST)
            conn.request('DELETE', '/api/v1alpha/block/volumes/' + volume_id, json.dumps(data), headers)
            resp = conn.getresponse()
            body = resp.read()
            LOG.info("status:%s, reason:%s, response:%s"%(resp.status, resp.reason, body))
            if resp.status not in [200, 201, 202]:
                raise Exception(body)
        finally:
            if conn:
                conn.close()

    def _get_volume(self, volume_id):
        conn = None
        headers = {"Content-type": "application/json"}
        try:
            conn = httplib.HTTPConnection(self.HOST)
            conn.request('GET', '/api/v1alpha/block/volumes/' + volume_id, None, headers)
            resp = conn.getresponse()
            body = resp.read()
        finally:
            if conn:
                conn.close()
        LOG.info("status:%s, reason:%s, response:%s" % (resp.status, resp.reason, body))
        if resp.status not in [200, 201, 202]:
            raise Exception(body)
        return json.loads(bytes.decode(body))

def resource_mapping():
    return {
        'OS::OpenSDS::Volume':OsdsVolume,
    }
```
### 参考
https://docs.openstack.org/heat/latest/getting_started/on_devstack.html

https://wiki.openstack.org/wiki/Heat/GettingStartedUsingDevstack

https://docs.openstack.org/project-install-guide/orchestration/ocata/launch-instance.html