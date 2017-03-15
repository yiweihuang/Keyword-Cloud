#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import json

if len(sys.argv) < 2:
    print('Usage: python3 [].py contents')
    sys.exit()
else:
    hash_key = sys.argv[1]
    hash_value = sys.argv[1]

print(hash_key)
