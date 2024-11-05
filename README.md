# caminsdaigua
Procés d'incorporació de les dades de rieres, rierols i recs  de Catalunya a OpenStreetMap

## Com ho farem?

A la carpeta "data_osm" hi teniu les dades de cursos d'aigua de l'ICGC per comarques. El procés és el següent.

1) Obrir les dades de l'ICGC amb JOSM.
2) Descarregar com una capa nova les dades de rieres, rierols i recs amb la query següent.

```
[out:xml][timeout:90][bbox:{{bbox}}];
(
  nwr["waterway"="stream"];
  nwr["waterway"="river"]; // aquesta només per no confondre
  nwr["waterway"="ditch"];
  nwr["waterway"="drain"];
  nwr["waterway"="canal"];
);
(._;>;);
out meta;

```
3) Afegir els cursos que falten amb les etiquetes pertinents (particularment `intermittent=yes`, si escau). Comproveu que els cursos estan connectats quan calgui. Sempre que es pugui, posar túnels i/o guals, quan escaigui. Cal fer les comprovacions pertinents amb l'ortofoto de l'ICGC.
4) Pujar les dades de mica en mica, intenteu no sobrepassar els 200 elements per cada pujada. Tingueu en compte que la ubicació moltes vegades és aproximada i feta a partir de la capa 1:50.000. En conseqüència, si us plau, reviseu amb l'ortofoto de l'ICGC.
5) Dubtes, al grup de Telegram. Salut i mapes.


