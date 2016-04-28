xquery version "3.1";

module namespace cwb-cobra-rdf   = "http://bibfram.es/cwb/cobra/rdf";

import module namespace functx  = "http://www.functx.com";
declare namespace cbo		   = "http://comicmeta.org/cbo/";
declare namespace cwb		   = "http://bibfram.es/cwb/";
declare namespace h = "http://www.w3.org/1999/xhtml";
declare namespace marcxml       = "http://www.loc.gov/MARC21/slim";
declare namespace rdf           = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace rdfs          = "http://www.w3.org/2000/01/rdf-schema#";

declare namespace oa			= "http://www.w3.org/ns/oa#";
declare namespace ex            = "http://example.org/";
declare namespace foaf		  = "http://xmlns.com/foaf/0.1/";
declare namespace skos		  = "http://www.w3.org/2004/02/skos/core#";
declare namespace dcterms       = "http://purl.org/dc/terms/";
declare namespace schema        = "http://schema.org/";
declare namespace bf            = "http://bibframe.org/vocab/";
declare namespace madsrdf       = "http://www.loc.gov/mads/rdf/v1#";
declare namespace relators      = "http://id.loc.gov/vocabulary/relators/";
declare namespace identifiers   = "http://id.loc.gov/vocabulary/identifiers/";
declare namespace notes         = "http://id.loc.gov/vocabulary/notes/";
declare namespace mods          = "http://www.loc.gov/mods/v3";

declare variable $cwb-cobra-rdf:cobra := "http://ivmooc-cobra2.github.io/";
declare variable $cwb-cobra-rdf:cbo := "http://comicmeta.org/cbo/";
declare variable $cwb-cobra-rdf:dc := "http://purl.org/dc/elements/1.1/";
declare variable $cwb-cobra-rdf:dcterms := "http://purl.org/dc/terms/";
declare variable $cwb-cobra-rdf:foaf := "http://xmlns.com/foaf/0.1/";
declare variable $cwb-cobra-rdf:rdf := "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare variable $cwb-cobra-rdf:schema := "http://schema.org/";

(: http://ivmooc-cobra2.github.io/resources/fan/530 :)

declare function cwb-cobra-rdf:get-fan-name(
    $fan as node()
) as item()* {
    if ($fan/*[@property eq $cwb-cobra-rdf:foaf||"title"][. ne "NULL"]) then
        (
            (
                (
                    $fan/*[@property eq $cwb-cobra-rdf:foaf||"firstName"]
                    [normalize-space(.) and . ne "NULL"], 
                    $fan/*[@property eq $cwb-cobra-rdf:foaf||"surname"]
                    [normalize-space(.) and . ne "NULL"]
                ) => string-join(" ")
            ), $fan/*[@property eq $cwb-cobra-rdf:foaf||"title"]
        ) => string-join(", ")
    else 
        (
            (
                $fan/*[@property eq $cwb-cobra-rdf:foaf||"firstName"]
                [normalize-space(.) and not(. eq "NULL")], 
                $fan/*[@property eq $cwb-cobra-rdf:foaf||"surname"]
                [normalize-space(.) and not(. eq "NULL")]
            ) => string-join(" ")
        )  
    
    
};


declare function cwb-cobra-rdf:get-fan-gender(
    $fan as node()
) as item()* {
if (
    $fan/*[@property eq $cwb-cobra-rdf:foaf||"gender"][. eq "F"]
    ) then 
        <h:img id="female-glyph" src="/static/resources/img/woman.svg" alt="female glyph"/>
    else if (
        $fan/*[@property eq $cwb-cobra-rdf:foaf||"gender"][. eq "M"]
    ) then
        <h:img id="male-glyph" src="/static/resources/img/man.svg" alt="male glyph"/>
    else ()
};

declare function cwb-cobra-rdf:get-fan-places(
$fan as node()
) as item()* {
let $place := $fan/*[@rel eq $cwb-cobra-rdf:schema||"address"]/@resource/data()
return
db:attribute("cobra-rdf", $place, "about")/..
};

declare function cwb-cobra-rdf:get-fan-place-uris(
$fan as node()
) as item()* {
cwb-cobra-rdf:get-fan-places($fan)/@about/string()
};

declare function cwb-cobra-rdf:get-fan-letters(
$fan as node()
) as item()* {
let $letter := $fan/*[@rel eq $cwb-cobra-rdf:foaf||"made"]/@resource/data()
return
db:attribute("cobra-rdf", $letter, "about")/..

};

declare function cwb-cobra-rdf:get-fan-letter-uris(
$fan as node()
) as item()* {
cwb-cobra-rdf:get-fan-letters($fan)/@about/string()
};

declare function cwb-cobra-rdf:get-fan-letters-by-place(
$fan as node()
) as item()* {
for $place at $pos in cwb-cobra-rdf:get-fan-place-uris($fan)
let $letter :=
db:attribute("cobra-rdf", $place, "resource")/..[@rel eq $cwb-cobra-rdf:schema||"locationCreated"]/..  
return $letter
};

declare function cwb-cobra-rdf:get-fan-letters-by-date(
$fan as node()
) as item()* {
<letters>{
for $issue at $pos in cwb-cobra-rdf:get-fan-issues($fan)
let $letter :=
<letter date="{$issue/*[@property eq $cwb-cobra-rdf:cbo||"publicationDate"]/string()}">{
$issue/*[@rel eq $cwb-cobra-rdf:cbo||"fanLetter"]/@resource[. = cwb-cobra-rdf:get-fan-letter-uris($fan)]/string()
}</letter>
order by $letter/@date
return $letter
}</letters>        
};

declare function cwb-cobra-rdf:make-fan-letter-links(
$letters as item()*,
$place as xs:string
) as item()* {    
for $letter in $letters/letter[@place = $place]
return        
<h:a href="{$letter}" class="image-link"><h:img class="letter-glyph" src="/static/resources/img/letter.svg" alt="letter marker glyph"/></h:a>        

};

declare function cwb-cobra-rdf:make-fan-letter-list(
$fan as node()    
) as item()* {
let $letters := cwb-cobra-rdf:get-fan-letters-by-date($fan)
for $letter in $letters/letter
return
<h:div class="letter" rel="{$cwb-cobra-rdf:foaf||'made'}" resource="{$letter}">{
let $title :=
<h:h3>{db:attribute("cobra-rdf", $letter, "about")/../*[@property eq $cwb-cobra-rdf:dc||"title"]/string()}</h:h3>
return $title
}</h:div>
};


declare function cwb-cobra-rdf:get-fan-letters-by-date-and-place(
$fan as node()
) as item()* {
    <letters>{
        for $issue at $pos in cwb-cobra-rdf:get-fan-issues($fan)
        let $letter-uri :=
            $issue/*[@rel eq $cwb-cobra-rdf:cbo||"fanLetter"]/@resource[. = cwb-cobra-rdf:get-fan-letter-uris($fan)]/string()
        let $place :=
            db:attribute("cobra-rdf", $letter-uri, "about")/../*[@rel eq $cwb-cobra-rdf:schema||"locationCreated"]/@resource/string()
        let $letter :=
            <letter date="{$issue/*[@property eq $cwb-cobra-rdf:cbo||"publicationDate"]/string()}" place="{$place}">{
                $letter-uri                
            }</letter>
        order by $letter/@date
        return $letter
    }</letters>        
};


declare function cwb-cobra-rdf:get-fan-issues(
$fan as node()
) as item()* {
let $issue-uris :=
$fan/*[@rel eq $cwb-cobra-rdf:foaf||"made"]/@resource/data()
for $i in $issue-uris
return
db:attribute("cobra-rdf", $i, "resource")/..[@rel eq $cwb-cobra-rdf:cbo||"fanLetter"]/..
};

declare function cwb-cobra-rdf:get-fan-geo(
$fan as node()
) as item()* {
let $place-uris := cwb-cobra-rdf:get-fan-place-uris($fan)
for $p in $place-uris
let $geo-uri := db:attribute("cobra-rdf", $p, "about")/../*[@rel eq $cwb-cobra-rdf:schema||"geo"]/@resource/string()
for $g in $geo-uri
return <geo>{
    <lat>{
        db:attribute("cobra-rdf", $g, "about")/../*[@property eq $cwb-cobra-rdf:schema||"latitude"]/string()
        }</lat>,
    <lon>{
        db:attribute("cobra-rdf", $g, "about")/../*[@property eq $cwb-cobra-rdf:schema||"longitude"]/string()
        }</lon>
    }</geo>

};	

declare function cwb-cobra-rdf:get-fan-network-by-place(
    $fan as node()
) as item()* {
    for $x in cwb-cobra-rdf:get-fan-letters-by-date-and-place($fan)/letter
    let $comic :=
        let $volume := db:attribute("cobra-rdf", $x/string(), "resource")/../../*[@rel eq $cwb-cobra-rdf:cbo||"issueOf"]/@resource/string()
        let $series := db:attribute("cobra-rdf", $volume, "about")/../*[@rel eq $cwb-cobra-rdf:cbo||"volumeOf"]/@resource/string()
        let $name := 
            <series name="{
                db:attribute("cobra-rdf", $series, "about")/../*[@property eq $cwb-cobra-rdf:schema||"name"]/string()
            }">{$series}</series>
        return $name
    
        
    let $pair :=
        <pair date="{$x/@date/data() => substring-before("-")}">{
            <source name="{cwb-cobra-rdf:get-fan-name($fan)}">{$fan/@about/string()}</source>,
            $comic
        }</pair>
    return $pair
};

declare function cwb-cobra-rdf:make-fan-network(
    $fan as node()
) as item()* {
  let $nodes := 
    for $pair in cwb-cobra-rdf:get-fan-network-by-place($fan)/*
    let $name := $pair/@name/string()
    group by $key := $pair/string()
    count $count
    return         
        <node id="n{$count}" uri="{$key}">{
            distinct-values($pair/@name)
        }</node>        
let $edges :=
    for $pair in cwb-cobra-rdf:get-fan-network-by-place($fan)/series
    count $count
    return 
        (<edge id="e{$count}" source="n1" target="{$nodes[if ($pair[self::series] = @uri/data()) then true() else false()]/@id}" weight="{
            
                    concat(
                        "n1",$nodes[if ($pair[self::series] = @uri/data()) then true() else false()]/@id
                    )
            
        }"/>, $pair[self::source])
let $edges2 :=
    for $e in $edges
    group by $key := $e/@weight/string()
    count $count
    let $weight := count($e)
    let $e :=
        <edge id="e{$count}" source="{$e[1]/@source}" target="{$e[1]/@target}" weight="{$weight}"/>
    return $e
return (
    let $node :=
        for $n in $nodes
        return
            <node id="{$n/@id}">{$n/string()}</node>
    return $node,
    $edges2
)  
    
};


declare function cwb-cobra-rdf:transform-fan-network-nodes(
    $fan as node()
) as xs:string* {
    string-join(("id,name"||"&#10;",    
    let $seq := cwb-cobra-rdf:make-fan-network($fan)
    for $s in $seq[self::node]
    let $nodes := (        
        $s/@id/string()||","||'"'||$s/string()||'"'||"&#10;"            
    )    
    return $nodes))
                   
};

declare function cwb-cobra-rdf:transform-fan-network-edges(
    $fan as node()
) as xs:string* {
    string-join(("source,target,weight"||"&#10;",    
        let $seq := cwb-cobra-rdf:make-fan-network($fan)
        for $s in $seq[self::edge]
        let $edges := (        
            $s/@source/string()||","||$s/@target/string()||","||$s/@weight/string()||"&#10;"            
        )
        
        return $edges))
    
};

















