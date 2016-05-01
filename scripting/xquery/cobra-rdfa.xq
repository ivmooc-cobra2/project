import module namespace functx  = "http://www.functx.com";
declare variable $cobra := "http://ivmooc-cobra2.github.io/";
declare variable $cbo := "http://comicmeta.org/cbo/";
declare variable $dc := "http://purl.org/dc/elements/1.1/";
declare variable $dcterms := "http://purl.org/dc/terms/";
declare variable $foaf := "http://xmlns.com/foaf/0.1/";
declare variable $rdf := "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare variable $schema := "http://schema.org/";

(: let $groups :=
(for $fan in /span/span[@about][@typeof = "http://comicmeta.org/cbo/Fan"]
let $place := $fan/span[@rel="http://schema.org/address"]/@resource
group by $key := $place/string()
order by count($place) descending
return 
if (count($place) gt 1) then
<place>{
<address id="{$key}" count="{count($place)}">{
    let $a := db:attribute("cobra-rdf", $key, "about")/..
    let $b := db:attribute("cobra-rdf", $a/span[@rel = "http://schema.org/address"]/@resource/string())/..
    return $b,
    <fans>{$fan}</fans>
}</address>
}</place>
else ())
return $groups :) (: /*/fans/span[@about] :)(: /span[@property = "http://xmlns.com/foaf/0.1/gender"] :) (: count($groups/*/fans/span[@about]) :)
(: let $places :=
for $place in /span/span[@about][@typeof = "http://schema.org/Place"]
let $address := $place/span[@rel = "http://schema.org/address"]/@resource
let $geo := $place/span[@rel = "http://schema.org/geo"]/@resource
return
<place id="{$place/@about/data()}">{
    <address>{
        db:attribute("cobra-rdf", $address/string(), "about")/..
    }</address>,
    <geo>{
        db:attribute("cobra-rdf", $geo/string(), "about")/..
    }</geo>
}</place>
return count($places) :)
(: for $fan in /span/span[@about][@typeof = "http://comicmeta.org/cbo/Fan"]/@about/substring-after(., "fan/") :)
for $fan in /span/span[@about][@typeof = "http://comicmeta.org/cbo/Fan"]
let $id := $fan/@about/substring-after(., "fan/")
let $name :=
    if ($fan/*[@property eq $foaf||"title"][. ne "NULL"]) then
        (
            (
                (
                    $fan/*[@property eq $foaf||"firstName"]
                    [normalize-space(.) and . ne "NULL"], 
                    $fan/*[@property eq $foaf||"surname"]
                    [normalize-space(.) and . ne "NULL"]
                ) => string-join(" ")
            ), $fan/*[@property eq $foaf||"title"]
        ) => string-join(", ")
    else 
        (
            (
                $fan/*[@property eq $foaf||"firstName"]
                [normalize-space(.) and not(. eq "NULL")], 
                $fan/*[@property eq $foaf||"surname"]
                [normalize-space(.) and not(. eq "NULL")]
            ) => string-join(" ")
        )
let $place :=
    $fan/*[@rel eq $schema||'address']/@resource/data()                 
let $address :=
    db:attribute("cobra-rdf", $place, "about")/..
    /*[@rel eq $schema||"address"]/@resource/data()
let $address-links :=
    db:attribute("cobra-rdf", $address, "about")/..                                 
let $geo :=
    db:attribute("cobra-rdf", $place, "about")/..
    /*[@rel eq $schema||"geo"]/@resource/data()
let $content := (
<html xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">    
    <head prefix="og: http://ogp.me/ns# dc: http://purl.org/dc/terms/">
        <meta charset="utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />        
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
            <script src="//oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
            <script src="//oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
        <![endif]-->
        <title></title>
        <script type="text/css" src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"></script>
        <style type="text/css">
            <![CDATA[
            #work{
                background-color: lightblue;
                margin-top: 2%;
                margin-left: 1%;
                padding: 1%;
                border: 1px solid black;
            }
            #instance{
                margin-left: 1%;
            }
            #item{
                margin-left: 1%;
            }
            #annotation{
                margin-left: 1%;
                padding: 1%;
            
            }]]>
        </style>
        {
            let $meta := (
                <meta name="title" content="{$name}" />,
                <meta property="dc:title" content="{$name}" />,
                <meta property="og:title" content="{$name}" />,                                
                <meta name="author" content="{$name}" />,
                <meta name="dc:creator" content="{$name}" />
            )      
            return $meta            
        }
        <script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
        <script type="text/javascript" src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
    </head>
    <body
        prefix="cbo: http://comicmeta.org/cbo/ dc: http://purl.org/dc/elements/1.1/ dcterms: http://purl.org/dc/terms/ foaf: http://xmlns.com/foaf/0.1/ oa: http://www.w3.org/ns/oa# rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns# schema: http://schema.org/ skos: http://www.w3.org/2004/02/skos/core# xsd: http://www.w3.org/2001/XMLSchema#">
        <div id="wrapper" class="container">
            <h1 about="{'/'||$fan/@about => substring-after($cobra)}">{
                <span property="{$schema||'name'}">{$name}</span>
            }</h1>
            <dl>
                <dt>
                    <label for="{$rdf||'type'}">
                        <span>type</span>
                    </label>
                </dt>
                <dd>
                    <span property="{$rdf||'type'}">{$cbo||"Fan"}</span>
                </dd>
            </dl>
            <dl>
                <dt>
                    <label for="{$schema||'name'}">
                        <span><a href="{$schema||'name'}">name</a></span>
                    </label>
                </dt>
                <dd>
                    <span property="{$schema||'name'}">{$name}</span>
                </dd>
            </dl>            
            <div id="address" rel="{$schema||'address'}" resource="{'/'||$place => substring-after($cobra)}" typeof="{$schema||'Place'}">
                <h2><a href="{'/'||$place => substring-after($cobra)||'/'}">Address</a></h2>
                <div rel="{$schema||'address'}" typeof="{$schema||'PostalAddress'}" resource="{'/'||$address => substring-after($cobra)}">{
                    <dl>
                        <dt>
                            <label for="{$schema||'streetAddress'}">
                                <span><a href="{$schema||'streetAddress'}">Street address</a></span>
                            </label>
                        </dt>
                        <dd>
                            <span property="{$schema||'streetAddress'}">{
                                $address-links/*[@property = $schema||'streetAddress']/string()
                            }</span>
                        </dd>
                    </dl>,
                    <dl>
                        <dt>
                            <label for="{$schema||'addressLocality'}">
                                <span><a href="{$schema||'addressLocality'}">Address locality</a></span>
                            </label>
                        </dt>
                        <dd>
                            <span property="{$schema||'addressLocality'}">{
                                $address-links/*[@property = $schema||'addressLocality']/string()
                            }</span>
                        </dd>
                    </dl>,
                    <dl>
                        <dt>
                            <label for="{$schema||'addressRegion'}">
                                <span><a href="{$schema||'addressRegion'}">Address region</a></span>
                            </label>
                        </dt>
                        <dd>
                            <span property="{$schema||'addressRegion'}">{
                                $address-links/*[@property = $schema||'addressRegion']/string()
                            }</span>
                        </dd>
                    </dl>,
                    <dl>
                        <dt>
                            <label for="{$schema||'postalCode'}">
                                <span><a href="{$schema||'postalCode'}">Postal code</a></span>
                            </label>
                        </dt>
                        <dd>
                            <span property="{$schema||'postalCode'}">{
                                $address-links/*[@property = $schema||'postalCode']/string()
                            }</span>
                        </dd>
                    </dl>,
                    <dl>
                        <dt>
                            <label for="{$schema||'addressCountry'}">
                                <span><a href="{$schema||'addressCountry'}">Address country</a></span>
                            </label>
                        </dt>
                        <dd>
                            <span property="{$schema||'addressCountry'}">{
                                $address-links/*[@property = $schema||'addressCountry']/string()
                            }</span>
                        </dd>
                    </dl>
                }</div>
                
            </div>
        </div>
    </body>    
</html>
) => functx:change-element-ns-deep("http://www.w3.org/1999/xhtml", "")

return (: $content :) 

file:write("/home/tat2/datasci/ivmooc/client/ivmooc-cobra2.github.io/resources/fan/" || $id || "/index.xml", $content)
