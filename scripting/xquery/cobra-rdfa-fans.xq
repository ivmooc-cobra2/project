import module namespace functx  = "http://www.functx.com";

import module namespace cwb-cobra-rdf = "http://bibfram.es/cwb/cobra/rdf" at "/home/tat2/apps/basex/webapp/cwb2/cwb/modules/ivmooc/cobra-rdf.xqm";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace h = "http://www.w3.org/1999/xhtml";
declare variable $cobra := "http://ivmooc-cobra2.github.io/";
declare variable $cbo := "http://comicmeta.org/cbo/";
declare variable $dc := "http://purl.org/dc/elements/1.1/";
declare variable $dcterms := "http://purl.org/dc/terms/";
declare variable $foaf := "http://xmlns.com/foaf/0.1/";
declare variable $rdf := "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare variable $schema := "http://schema.org/";
declare variable $xslt-pi := processing-instruction xml-stylesheet {'type="text/xsl" href="/static/xsltforms/build/xsltforms.xsl"'};
declare variable $css-pi := processing-instruction css-conversion {"no"};


for $fan in /span/span[@about][@typeof = "http://comicmeta.org/cbo/Fan"]
let $id := $fan/@about/substring-after(., "fan/")
let $name := cwb-cobra-rdf:get-fan-name($fan)

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
(: let $letter-uri :=
    $fan/*[@rel eq $dc||'creator']/@resource/data() :)

let $sparql := 
``[PREFIX dc: <http://purl.org/dc/elements/1.1/> 
PREFIX cbo: <http://comicmeta.org/cbo/> 
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX schema: <http://schema.org/>
SELECT ?lat ?long 
WHERE {
  ?fan schema:address ?Place .
  ?Place schema:geo ?Geo .
  ?Geo schema:latitude ?lat .
  ?Geo schema:longitude ?long .
  FILTER(?fan = <`{$fan/@about/data()}`>)
}]``
let $xsltf := "file:///home/tat2/apps/basex/webapp/static/xsltforms/build/xsltforms.xsl"    
    let $pi-debug := processing-instruction {"xsltforms-option"} {"debug='no'"}
    let $pi-css := processing-instruction {"css-conversion"} {"no"}
    let $data := ()
    let $content := (
<h:html xmlns:h="http://www.w3.org/1999/xhtml"
    xmlns:xf="http://www.w3.org/2002/xforms"
    xmlns:ev="http://www.w3.org/2001/xml-events"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema">    
    <h:head prefix="og: http://ogp.me/ns# dc: http://purl.org/dc/terms/">
        <h:meta charset="utf-8" />
        <h:meta http-equiv="X-UA-Compatible" content="IE=edge" />        
        <h:meta name="viewport" content="width=device-width, initial-scale=1" />
        {
            let $meta := (
                <h:meta name="title" content="{$name}" />,
                <h:meta property="dc:title" content="{$name}" />,
                <h:meta property="og:title" content="{$name}" />,                                
                <h:meta name="author" content="{$name}" />,
                <h:meta name="dc:creator" content="{$name}" />
            )      
            return $meta            
        }        
        <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
            <script src="//oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
            <script src="//oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
        <![endif]-->
        <h:title>Fan page: {$name}</h:title>
                
        <!-- Latest compiled and minified CSS -->
        <h:link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous"/>
        <!-- Optional theme -->
        <h:link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous"/>        
        <h:style type="text/css">
        <![CDATA[
           #top{
               width: 100%;
               float: left;
           } 
           #locations{
               width: auto;
               
               float: left;
               
           }
           th{
               width: 10%;
           }
           td{
               width: auto;
           }
           .place{
               width: 100%;
               float: left;
           }
           .address{
               width: 100%;
               float: left;
           }
           #sgvzl{
	           width: 80%;
	           float: left;

           }
           #credits{
               width: 100%;
               float: left;
               clear: both;
               margin-top: 2%;
           }
           .location-marker{
               width: 1em;
               
           }
           #male-glyph{
               width: 1em;
           }
           #female-glyph{
               width: 1em;
           }
           .letter-glyph{
               width: 2em;
           }
           a img
           {
             border: 0 none;
           }
           .image-link
           {
             text-decoration: none !important;
             border: 0 none !important;
           }
           .image-link:hover{
               text-decoration: none !important;
               border: 0 none !important;
           }
           
        ]]>        
        </h:style>
        <h:script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js">/**/</h:script> 
        <h:script type="text/javascript" src="https://www.google.com/jsapi">/**/</h:script>
        <h:script type="text/javascript" id="sgvzlr_script" src="http://mgskjaeveland.github.io/sgvizler/v/0.6/sgvizler.min.js">/**/</h:script>
        <h:script type="text/javascript">
            sgvizler
                .defaultEndpointURL("http://bibfram.es/fuseki/cobra/query");                
     
            //// Leave this as is. Ready, steady, go!
            $(document).ready(sgvizler.containerDrawAll);
        </h:script>
        <!-- Latest compiled and minified JavaScript -->
        <h:script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous">/**/</h:script>        
        <xf:model id="default-model">
            <xf:instance id="geo-data">
                <data xmlns="">{
                    cwb-cobra-rdf:get-fan-geo($fan)    
                }</data>
            </xf:instance>
        </xf:model>
    </h:head>
    <h:body
        prefix="cbo: http://comicmeta.org/cbo/ dc: http://purl.org/dc/elements/1.1/ dcterms: http://purl.org/dc/terms/ foaf: http://xmlns.com/foaf/0.1/ oa: http://www.w3.org/ns/oa# rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns# schema: http://schema.org/ skos: http://www.w3.org/2004/02/skos/core# xsd: http://www.w3.org/2001/XMLSchema#">
        <h:div id="wrapper" class="container" about="{$fan/@about}" typeof="http://comicmeta.org/cbo/Fan">                    
            <h:div id="top">
                <h:h1>{
                    <span property="{$schema||'name'}">{$name}</span>,
                    cwb-cobra-rdf:get-fan-gender($fan)
                }</h:h1>
                <h:dl>
                    <h:dt>
                        <h:label for="http://comicmeta.org/cbo/Fan">
                            <h:span>type</h:span>
                        </h:label>
                    </h:dt>
                    <h:dd>
                        <h:span>http://comicmeta.org/cbo/Fan</h:span>
                    </h:dd>
                </h:dl>
                <h:dl>
                    <h:dt>
                        <h:label for="{$schema||'name'}">
                            <h:span><a href="{$schema||'name'}">name</a></h:span>
                        </h:label>
                    </h:dt>
                    <h:dd>
                        <h:span property="{$schema||'name'}">{$name}</h:span>
                    </h:dd>
                </h:dl>         
            </h:div>
            <h:div id="places">
            <h:h2>Locations</h:h2>
            <h:div id="locations">
            {           
            
            for $x in cwb-cobra-rdf:get-fan-letters-by-date-and-place($fan), 
            $place in $x/letter/@place/data()            
            group by $place            
            return
            <h:div class="place" rel="{$schema||'address'}" resource="{$place}" typeof="{$schema||'Place'}">
                <h:h3>
                    <h:a href="{$place}" class="image-link"><img class="location-marker" src="/static/resources/img/location.svg" alt="location marker glyph"/></h:a>                
                </h:h3>              
              
                <h:table class="table">                    
                    <h:tbody>
                        <h:tr>
                            <h:th>Letters</h:th>
                            {
                                for $link in cwb-cobra-rdf:make-fan-letter-links($x, $place)                                                
                                return (
                                    <h:td>{
                                        $link
                                    }</h:td>                             
                                )
                            }                                                        
                        </h:tr>
                        <h:tr>
                            <h:th>Dates</h:th>
                            {
                                for $date in $x/letter[. = cwb-cobra-rdf:make-fan-letter-links($x, $place)/@href/data()]/@date
                                return (
                                    <h:td>{
                                        $date/string()
                                    }</h:td>
                                )
                                
                            }
                        </h:tr>
                    </h:tbody>
                </h:table>
                {
                let $address := 
                    db:attribute("cobra-rdf", $place, "about")/..
                    /*[@rel eq $schema||"address"]/@resource/data()
                for $a at $pos2 in $address
                return                                                                                         
                <h:div class="address" rel="{$schema||'address'}" typeof="{$schema||'PostalAddress'}" resource="{
                    db:attribute("cobra-rdf", $a, "about")/../@about/data()
                }">{
                    <h:dl>
                        <h:dt>
                            <h:label for="{$schema||'streetAddress'}">
                                <h:span><h:a href="{$schema||'streetAddress'}">Street address</h:a></h:span>
                            </h:label>
                        </h:dt>
                        <h:dd>
                            <h:span property="{$schema||'streetAddress'}">{
                                db:attribute("cobra-rdf", $a, "about")/../*[@property = $schema||'streetAddress']/string()
                            }</h:span>
                        </h:dd>
                    </h:dl>,
                    <h:dl>
                        <h:dt>
                            <h:label for="{$schema||'addressLocality'}">
                                <h:span><a href="{$schema||'addressLocality'}">Address locality</a></h:span>
                            </h:label>
                        </h:dt>
                        <h:dd>
                            <h:span property="{$schema||'addressLocality'}">{
                                db:attribute("cobra-rdf", $a, "about")/../*[@property = $schema||'addressLocality']/string()
                            }</h:span>
                        </h:dd>
                    </h:dl>,
                    <h:dl>
                        <h:dt>
                            <h:label for="{$schema||'addressRegion'}">
                                <h:span><a href="{$schema||'addressRegion'}">Address region</a></h:span>
                            </h:label>
                        </h:dt>
                        <h:dd>
                            <h:span property="{$schema||'addressRegion'}">{
                                db:attribute("cobra-rdf", $a, "about")/../*[@property = $schema||'addressRegion']/string()
                            }</h:span>
                        </h:dd>
                    </h:dl>,
                    <h:dl>
                        <h:dt>
                            <h:label for="{$schema||'postalCode'}">
                                <h:span><h:a href="{$schema||'postalCode'}">Postal code</h:a></h:span>
                            </h:label>
                        </h:dt>
                        <h:dd>
                            <h:span property="{$schema||'postalCode'}">{
                                db:attribute("cobra-rdf", $a, "about")/../*[@property = $schema||'postalCode']/string()
                            }</h:span>
                        </h:dd>
                    </h:dl>,
                    <h:dl>
                        <h:dt>
                            <h:label for="{$schema||'addressCountry'}">
                                <h:span><h:a href="{$schema||'addressCountry'}">Address country</h:a></h:span>
                            </h:label>
                        </h:dt>
                        <h:dd>
                            <h:span property="{$schema||'addressCountry'}">{
                                db:attribute("cobra-rdf", $a, "about")/../*[@property = $schema||'addressCountry']/string()
                            }</h:span>
                        </h:dd>
                    </h:dl>
                }</h:div>
              }                   
            </h:div>                      
            }</h:div>
            </h:div>
            {
                cwb-cobra-rdf:make-fan-letter-list($fan)
            }          
            <h:div id="credits">Icons made by <h:a href="http://www.flaticon.com/authors/simpleicon" title="SimpleIcon">SimpleIcon</h:a> from <h:a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</h:a> is licensed by <h:a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</h:a></h:div>
        </h:div>        
    </h:body>    
</h:html>
)
let $doc := document {$pi-debug, $pi-css, $content}
let $t := xslt:transform-text($doc, $xsltf, map {"xsltforms_home": "http://localhost:8984/static/xsltforms/build/"})
return (: $content :) (: html:parse($t) :)
(: file:create-dir("/home/tat2/datasci/ivmooc/client/ivmooc-cobra2.github.io/resources/fan/" || $id) :)
(: file:write("/home/tat2/datasci/ivmooc/client/ivmooc-cobra2.github.io/resources/fan/" || $id || "/index.html", html:parse($t), map {"method": "html", "html-version": "5.0"}) :)

let $nodes := cwb-cobra-rdf:transform-fan-network-edges($fan)
return
file:write("/home/tat2/datasci/ivmooc/client/ivmooc-cobra2.github.io/resources/fan/" || $id || "/fan-edges.csv", $nodes, map {"method": "text"})

    