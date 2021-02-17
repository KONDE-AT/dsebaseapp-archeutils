xquery version "3.1";

(:~
 : This module provides a couple of variables (and some helper functions) to set ease the creation of ARCHE-RDF metadata representation
 : @author peter.andorfer@oeaw.ac.at
:)

module namespace archeutils="http://www.digital-archiv.at/ns/archeutils";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace functx = "http://www.functx.com";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace util = "http://exist-db.org/xquery/util";


declare variable $archeutils:constants_exist :=
    if (doc-available($app:data||'/meta/arche_constants.rdf'))
        then
            true()
        else
            false();
declare variable $archeutils:constants :=
    if ($archeutils:constants_exist)
        then
            doc($app:data||'/meta/arche_constants.rdf')//acdh:ACDH
        else
            <acdh:ACDH/>;


declare variable $archeutils:base_url := $archeutils:constants//acdh:TopColl/@url;
declare variable $archeutils:app_base_url := $archeutils:constants//acdh:AppBaseURL/text();
declare variable $archeutils:entity_url := $archeutils:base_url||"/entity";
declare variable $archeutils:available_date := <acdh:hasAvailableDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{current-date()}</acdh:hasAvailableDate>;
declare variable $archeutils:repoobject_constants : = $archeutils:constants//acdh:RepoObject/*;
declare variable $archeutils:resource_constants : = ($archeutils:repoobject_constants, $archeutils:constants//acdh:Resource/*);
declare variable $archeutils:agents := $archeutils:constants//acdh:MetaAgents/*;
declare variable $archeutils:collstruct := $archeutils:constants//acdh:CollStruct;
declare variable $archeutils:tei_lookups := $archeutils:constants//acdh:TeiLookUps;
declare variable $archeutils:person_lookups := $archeutils:constants//acdh:PersonLookUps;
declare variable $archeutils:place_lookups := $archeutils:constants//acdh:PlaceLookUps;
declare variable $archeutils:org_lookups := $archeutils:constants//acdh:OrgLookUps;
declare variable $archeutils:default_lang := $archeutils:constants//acdh:DefaultLang/text();


(:~
 : looks for a norm-data URL in any <tei:idno> and returns the first on found or the project-specific id
 : @param $item The node of the entitiy e.g. tei:place, tei:person, tei:org
 : @return A string used as ARCHE-ID

:)

declare function archeutils:get_entity_id($item as node()){
    let $default_id := concat($archeutils:entity_url, '/', data($item/@xml:id))
    let $ids := $item//tei:idno[
            contains(.//text(), 'd-nb.info') or
            contains(.//text(), 'geonames') or
            contains(.//text(), 'viaf')
        ]/text()
    let $result := if ($ids) then $ids else $default_id

    return
        $result
};


(:~
 : creates RDF Metadata describing the applications basic collection structure
 :
 : @param $cols A sequence of names of the collection, need to match the @name attribute and are used to genereate the collections identifier
 : @return An ARCHE RDF describing the collections
:)

declare function archeutils:dump_collections($cols as item()+) as node()*{
    let $topcol :=
        <acdh:TopCollection rdf:about="{$archeutils:base_url}">
            {$archeutils:collstruct//acdh:TopColl//*}
            {$archeutils:repoobject_constants}
            {$archeutils:available_date}
        </acdh:TopCollection>

    let $childCols :=
        for $x in $cols
            let $col :=
                <acdh:Collection rdf:about="{$archeutils:base_url||'/'||$x}">
                    <acdh:isPartOf rdf:resource="{$archeutils:base_url}"/>
                    {$archeutils:available_date}
                    {$archeutils:collstruct//acdh:DataColl[@name=$x]//*}
                    {$archeutils:repoobject_constants}
                    {$archeutils:available_date}
                </acdh:Collection>
            where $col/acdh:hasTitle
            return
                $col

    let $RDF :=
        <rdf:RDF
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
            xml:base="https://id.acdh.oeaw.ac.at/">
            {$topcol}
            {$childCols}
            {$archeutils:agents}
        </rdf:RDF>

    return $RDF
};


(:~
 : generates resource specific attributes derived from acdh_TeiLookUps and the passed in TEI-Document
 :
 : @param $doc The root element of a TEI Document (or the node from wich the provided xpaths should be evaluated)
 : @return ARCHE properties
:)

declare function archeutils:populate_tei_resource($lookup as item(), $item as node()) as node()*{

for $x in $lookup/*
    let $lang := if (exists(data($x/@lang))) then data($x/@lang) else $archeutils:default_lang 
    let $el_name := name($x)
    let $el_type := data($x/@type)
    let $el_xpath := $x/text()
    let $el_value := if ($el_type eq 'no_eval') then $el_xpath else util:eval($el_xpath)
    let $el :=
        switch ($el_type)
        case 'date' return element {$el_name}  {attribute rdf:datatype { "http://www.w3.org/2001/XMLSchema#date" }, $el_value }
        case 'resource_many' return for $res_url in $el_value return element {$el_name} {attribute rdf:resource { $res_url }}
        case 'resource' return element {$el_name} {attribute rdf:resource { $el_value }}
        case 'no_eval' return element {$el_name} {$el_xpath }
        case 'literal_no_lang' return element {$el_name} {$el_value }
        default return element {$el_name}  {attribute xml:lang { $lang }, $el_value }
    where $el_value
    return $el
};
