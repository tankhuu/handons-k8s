#!/bin/sh
services="aggregateservice edtaservice gateway geocalculationservice geocodeservice importingservice ivinservice overlayservice plannedrolloverservice reportservice routingmigration routingservice rresservice tnxhubservice"

for service in $services; do
echo $service
helm package $service -d athena/charts/
done