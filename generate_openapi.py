#!/usr/bin/env python3
"""
Generate OpenAPI specification from FastAPI app.

This script imports the FastAPI app and exports its OpenAPI schema to a JSON file.
"""
import json
import sys
from pathlib import Path

# Add parent directory to path to import memory module
sys.path.insert(0, str(Path(__file__).parent))

from memora.web.server import app

def generate_openapi_spec(output_path: str = "openapi.json"):
    """Generate OpenAPI spec and save to file."""
    # Get the OpenAPI schema from the app
    openapi_schema = app.openapi()

    # Write to file
    output_file = Path(output_path)
    with open(output_file, 'w') as f:
        json.dump(openapi_schema, f, indent=2)

    print(f"✓ OpenAPI specification generated: {output_file.absolute()}")
    print(f"  - Title: {openapi_schema['info']['title']}")
    print(f"  - Version: {openapi_schema['info']['version']}")
    print(f"  - Endpoints: {len(openapi_schema['paths'])}")

    # List endpoints
    print("\n  Endpoints:")
    for path, methods in openapi_schema['paths'].items():
        for method in methods.keys():
            if method.upper() in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                endpoint_info = methods[method]
                summary = endpoint_info.get('summary', 'No summary')
                tags = ', '.join(endpoint_info.get('tags', ['untagged']))
                print(f"    {method.upper():6} {path:30} [{tags}] - {summary}")

if __name__ == "__main__":
    output = sys.argv[1] if len(sys.argv) > 1 else "openapi.json"
    generate_openapi_spec(output)
