#!/usr/bin/env python3

import argparse
import subprocess


tmplate = '''[Interface]
ListenPort = {port}
PrivateKey = {private_key}'''

peer_tmpl = '''
[Peer]
PublicKey = {public_key}
AllowedIPs = {routed_networks}
PersistentKeepalive = {keepalive_sec}
'''

masquerade_commands = '''
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o {nat_interface} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o {nat_interface} -j MASQUERADE
'''

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-p', '--port', default=51820, type=int)
    parser.add_argument('-l', '--keep-alive-inetrval', type=int, default=0)

    subparsers = parser.add_subparsers(help='sub-command help', dest='mode')
    
    parser_server = subparsers.add_parser('server')
    parser_server.add_argument('network')
    parser_server.add_argument('-m', '--masquerade', help='NAT interface')

    parser_client = subparsers.add_parser('client')
    parser_client.add_argument('server_address')
    parser_client.add_argument('client_network')

    args = parser.parse_args()
    if args.mode == 'server':
        server_private_key = subprocess.run(['wg', 'genkey'], capture_output=True).stdout.decode('utf-8')
        config = tmplate.format(port=args.port, private_key=server_private_key)
        config += 'Address = {}\n'.format(args.network)

        if args.masquerade:
            config += masquerade_commands.format(nat_interface=args.masquerade)
        
        print(config)
    else:
        server_config_str = None
        server_priv_key = None
        with open('/etc/wireguard/wg0.conf') as f:
            server_config_str = f.read()
        with open('/etc/wireguard/private') as f:
            server_priv_key = f.read()
        
        client_private_key = subprocess.run(['wg', 'genkey'], capture_output=True).stdout.decode('utf-8').strip()
        client_public_key = subprocess.run(['wg', 'pubkey'], capture_output=True, input=client_private_key.encode()).stdout.decode('utf-8').strip()
        server_public_key = subprocess.run(['wg', 'pubkey'], capture_output=True, input=server_priv_key.encode()).stdout.decode('utf-8').strip()

        client_conf = tmplate.format(port=args.port, private_key=client_private_key)
        client_conf += peer_tmpl.format(public_key=server_public_key, routed_networks='0.0.0.0/0', keepalive_sec=args.keep_alive_inetrval)
        client_conf += 'Endpoint = {server}'.format(server=args.server_address)
        print('#CLIENT CONF:')
        print(client_conf)

        server_config_str += peer_tmpl.format(public_key=client_public_key, routed_networks=args.client_network, keepalive_sec=args.keep_alive_inetrval)
        print('#SERVER CONF:')
        print(server_config_str)

if __name__ == '__main__':
    main()