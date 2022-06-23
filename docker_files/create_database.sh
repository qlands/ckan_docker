#!/bin/bash
su - postgres -c 'createdb -O tmp_role tmp_database -E utf-8'
