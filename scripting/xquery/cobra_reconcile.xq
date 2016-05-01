import module namespace cwb-cobra = "http://bibfram.es/cwb/cobra" at "/home/tat2/apps/basex/webapp/cwb/modules/ivmooc/cobra.xqm";
import module namespace functx = "http://www.functx.com";
declare namespace g = "http://graphml.graphdrawing.org/xmlns";

let $graph :=
    for $row at $p in /csv/record	
    let $nodeGroup :=
        <nodes>{
            for $r in $row/*
            let $nodes :=     
                typeswitch($r)
                    case $p as element(fan)
                        return     
                            <n type="person" id="{$p}" gender="{$p/../gender}">{                    
                                if ($p/../fanTitle[normalize-space(.) and not(. eq "NULL")]) then
                                    ((($p/../firstName[normalize-space(.) and not(. eq "NULL")], $p/../surname[normalize-space(.) and not(. eq "NULL")]) => string-join(" ")), $p/../fanTitle) => string-join(", ")
                                else ($p/../firstName[normalize-space(.) and not(. eq "NULL")], $p/../surname[normalize-space(.) and not(. eq "NULL")]) => string-join(" ")
                            }</n>
                    case $s as element(series)
                        return
                            <n type="series" id="{$s}">{
                                $s/../seriesTitle/string()
                            }</n>    
                    (: case $i as element(issueInstance)
                        return 
                            <n type="issue" id="{$i}" number="{$i/../issueNumber}">{
                                "Issue " || $i/../issueNumber/string()
                            }</n> :)
                    (: case $l as element(letter)
                        return
                            <n type="letter" id="{$l}">{
                                "Letter" (: || $p :)
                            }</n> :)                    
                    default return ()                   
           return $nodes
        }</nodes>            
    return $nodeGroup
let $writers :=
    for $writer in $graph/n[@type = "person"]
    group by $key := $writer/@id/data()        
    return $writer => functx:distinct-deep()
let $series :=
    for $series in $graph/n[@type = "series"]
    group by $key := $series/@id/data()
    return $series => functx:distinct-deep()
(: let $issues :=
    for $issue in $graph/n[@type = "issue"]
    group by $key := $issue/@id/data()
    return $issue => functx:distinct-deep() :)
(: let $letters :=
    for $letter in $graph/n[@type = "letter"]
    group by $key := $letter/@id/data()
    return $letter => functx:distinct-deep() :) 
let $nodes := (
    $writers, $series(: , $issues :)(: , $letters :)
)
let $edge1 := (
    for $e in $graph
    group by $key := concat($e/n[@type = "person"]/@id/data(), "_", $e/n[@type = "series"]/@id/data())
    (: let $key := concat($e/n[@type = "person"]/@id/data(), "_", $e/n[@type = "series"]/@id/data()) :)
    return <group count="{count($e)}" key="{$key}">{$e => functx:distinct-deep()}</group>   
)
(: let $edge2 := (
    for $e in $graph
    group by $key := concat($e/n[@type = "letter"]/@id/data(), "_", $e/n[@type = "issue"]/@id/data())
    let $key := concat($e/n[@type = "letter"]/@id/data(), "_", $e/n[@type = "issue"]/@id/data())
    return <group count="{count($e)}" key="{$key}">{$e => functx:distinct-deep()}</group>   
) :)
(: let $edge3 := (
    for $e in $graph
    (: group by $key := concat($e/n[@type = "issue"]/@id/data(), "_", $e/n[@type = "series"]/@id/data()) :)
    (: let $key := concat($e/n[@type = "issue"]/@id/data(), "_", $e/n[@type = "series"]/@id/data())
    return <group count="{count($e)}" key="{$key}">{$e => functx:distinct-deep()}</group> :)   
) :)
let $edges := (
    $edge1 (: $edge2, :) (: $edge3 :)
)
let $result := (
    
    for $n in $nodes
    order by $n/@id
    return 
        <g:node id="{$n/@id/data()}">{
            if ($n/@gender eq "M") then
                <g:data key="d0">blue</g:data>
            else if ($n/@gender eq "F") then
                <g:data key="d0">red</g:data>
            else if ($n/@gender eq "NULL") then
                <g:data key="d0">gray</g:data>
            else <g:data key="d0">yellow</g:data>,            
            <g:data key="d2">{$n/string()}</g:data>
            
        }</g:node>,
    for $e at $p in $edges    
    return (       
        <g:edge id="e{$p}" source="{$e/nodes/n[@type = 'person']/@id/data()}" target="{$e/nodes/n[@type = 'series']/@id/data()}">{
            <g:data key="d1">{concat($e/@count, ".0")}</g:data>
        }</g:edge>      
        (: <g:edge id="e{$p}" source="{$e/nodes/n[@type = 'letter']/@id/data()}" target="{$e/nodes/n[@type = 'issue']/@id/data()}">{
            <g:data key="d1">{concat($e/@count, ".0")}</g:data>
        }</g:edge>, :)
        (: <g:edge id="e{$p}" source="{$e/nodes/n[@type = 'issue']/@id/data()}" target="{$e/nodes/n[@type = 'series']/@id/data()}">{
            <g:data key="d1">{concat($e/@count, ".0")}</g:data>
        }</g:edge> :)                
    )
)
let $update :=   
   for $r at $p in $result
   return
       if ($r[self::g:edge]) then
           copy $c := $r
           modify (   
               replace value of node $c/@id with "e"||$p
           ) 
           return $c  
       else $r
     
return 
file:write("/home/tat2/Desktop/cobra.graphml", 
    <g:graphml 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns 
    http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">{
    <g:key id="d0" for="node" attr.name="color" attr.type="string">
        <g:default>yellow</g:default>
    </g:key>,
    <g:key id="d1" for="edge" attr.name="weight" attr.type="double"/>,
    <g:key id="d2" for="node" attr.name="label" attr.type="string"/>,
    <g:graph id="G" edgedefault="undirected">{
        $update
    }</g:graph>
}</g:graphml>
)




(:
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns 
    http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
    <key id="d0" for="node" attr.name="color" attr.type="string">
        <default>yellow</default>
    </key>
    <key id="d1" for="edge" attr.name="weight" attr.type="double"/>
    <key id="d2" for="node" attr.name="label" attr.type="string"/>
    <graph id="G" edgedefault="undirected">
        <node id="n0">
            <data key="d0">green</data>
            <data key="d2">Name</data>
        </node>
        <node id="n1"/>
        <node id="n2">
            <data key="d0">blue</data>
        </node>
        <node id="n3">
            <data key="d0">red</data>
        </node>
        <node id="n4"/>
        <node id="n5">
            <data key="d0">turquoise</data>
        </node>
        <edge id="e0" source="n0" target="n2">
            <data key="d1">1.0</data>
        </edge>
        <edge id="e1" source="n0" target="n1">
            <data key="d1">1.0</data>
        </edge>
        <edge id="e2" source="n1" target="n3">
            <data key="d1">2.0</data>
        </edge>
        <edge id="e3" source="n3" target="n2"/>
        <edge id="e4" source="n2" target="n4"/>
        <edge id="e5" source="n3" target="n5"/>
        <edge id="e6" source="n5" target="n4">
            <data key="d1">1.1</data>
        </edge>
    </graph>
</graphml>
:)