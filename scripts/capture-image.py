import sys
import traceback
import SoftLayer

def main(params):
    try:
        if len(params) < 4:
            print("insufficient parameters!")
        else:
            sl_user = str(params[0])
            sl_apikey = str(params[1])
            instance_id = int(params[2])
            image_name = str(params[3])

            client = SoftLayer.create_client_from_env(username=sl_user, api_key=sl_apikey)
            mgr = SoftLayer.VSManager(client)

            image_info = mgr.capture(instance_id, image_name)

            print(image_info)
    except Exception:
        print(traceback.format_exc())

if __name__ == '__main__':
    main(sys.argv[1:])