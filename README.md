# dsebaseapp-archeutils
utility module to ease the creation of ARCHE-RDF

This modules tries to ease the curation effort needed to describe a dataset of XML/TEI documents managed by a dsebaseapp as an ARCHE-RDF.
Its main idea is to reuse as much existing metadata as possible and avoid any potential data duplication.
The module consits of three main parts
* an XQuery module named `archeutils.xql`
* several API endpoints for serialising ARCHE-RDF data
* a single configuration file for project/resource specific data `data/meta/arche_constants.rdf`

Whereas the first two parts are generic and therefore provided as reusable module, the configuration file needs to customized for each dsebaseapp-project and is therefore NOT included in this module.

## archeutils.xql

The XQuery module named `archeutils.xql` exposes several variables needed to create an ARCHE-RDF fetched from
* the application structure
*  `data/meta/arche_constants.rdf`

## API-Endpoints

ARCHE RDF/XML serialisations of
* the projct's 'administrative persons': `archeutils/dump-arche-agents.xql`
* the projct's collection and collection structure: `archeutils/dump-arche-cols.xql`
* resources per collection: `ump-arche-resources.xql?col-name={editions}&starting-at={0}&length={10}`

## data/meta/arche_constants.rdf

(Ab)uses [repo-schema](https://github.com/acdh-oeaw/repo-schema) to provide project specific data. E.g. [schnitzler-tagebuch-data/meta/arche_constants.rdf](https://github.com/acdh-oeaw/schnitzler-tagebuch-data/blob/master/meta/arche_constants.rdf)
