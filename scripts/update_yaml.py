import argparse
from ruamel.yaml import YAML

def update_yaml(file_path, param_name, param_value, node_name, namespace):
    """Updates or adds a parameter value in the YAML file, preserving formatting."""
    yaml = YAML()
    yaml.preserve_quotes = True

    try:
        # Load the YAML file
        with open(file_path, 'r') as file:
            data = yaml.load(file) or {}

        # Search for the node to update
        target_node = None
        # Iterate through the nodes to find the specified node
        for node in data[namespace]:
            if node == node_name:
                target_node = node
                break
        
        print(target_node)

        if target_node:
            # Ensure the node exists and update the parameter
            if "ros__parameters" not in data[namespace][target_node]:
                data[namespace][target_node]["ros__parameters"] = {}

            data[namespace][target_node]["ros__parameters"][param_name] = float(param_value)
        else:
            # If the target node doesn't exist, create a new one or default node
            print(f"Node '{node_name}' not found. Adding new parameter to 'default_node'.")
            target_node = "default_node"
            data[namespace][target_node] = {"ros__parameters": {param_name: float(param_value)}}

        # Save the updated YAML file
        with open(file_path, 'w') as file:
            yaml.dump(data, file)

        print(f"Parameter '{param_name}' updated to '{param_value}' in node '{target_node}'.")

    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Update a parameter in a YAML file.")
    parser.add_argument("--file", required=True, help="Path to the YAML file.")
    parser.add_argument("--param", required=True, help="Parameter name to update.")
    parser.add_argument("--value", required=True, help="New value for the parameter.")
    parser.add_argument("--node", required=True, help="Node name for where to put the parameter.")
    parser.add_argument("--namespace", required=True, help="namespace for where to put the parameter.")

    args = parser.parse_args()

    # Call the update function
    update_yaml(args.file, args.param, args.value, args.node, args.namespace)
