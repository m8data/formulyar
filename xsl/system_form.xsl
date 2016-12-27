<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:math="http://exslt.org/math" xmlns:func="http://exslt.org/functions" extension-element-prefixes="func" xmlns:m8="http://m8data.com">
	<xsl:include href="get_name.xsl"/>
	<!--<xsl:include href="../../../m8/type.xsl"/>-->
	<!--

	информация по стартовому xml (здесь излишне читать порт, т.к. иногда он нужен)-->
	<xsl:variable name="authPath" select="'m8/author'"/>
	<xsl:variable name="start" select="/*"/>
	<!--<xsl:variable name="m8root" select="$start/@DOCUMENT_ROOT"/>-->
	<xsl:variable name="ctrl" select="$start/@ctrl"/>
	<xsl:variable name="fact" select="$start/@fact"/>
	<xsl:variable name="author" select="$start/@author"/>
	<xsl:variable name="avatar" select="$start/@avatar"/>
	<xsl:variable name="quest" select="$start/@quest"/>
	<xsl:variable name="modifier" select="$start/@modifier"/>
	<xsl:variable name="xsStartID" select="m8:dir( $fact )"/>
	<xsl:variable name="sStartID" select="m8:dir( $fact, $quest )"/>
	<xsl:variable name="startID" select="concat( $start/@prefix, 'a/', $ctrl, '/', $sStartID )"/>
	<xsl:variable name="startGroup" select="$start/@group"/>
	<xsl:variable name="user" select="$start/@user"/>
	<xsl:variable name="time" select="$start/@time"/>
	<xsl:variable name="adminMode" select="$start/@adminMode or $start/@debug"/>
	<xsl:variable name="localtime" select="$start/@localtime"/>
	<!--<xsl:variable name="avatarTypeRoot" select="m8:path( $avatar )"/>-->
	<xsl:variable name="parent">
		<xsl:message>	--- parent --- </xsl:message>
		<xsl:call-template name="getParent">
			<xsl:with-param name="currentFactName" select="$fact"/>
			<!--<xsl:with-param name="currentQuestName" select="$quest"/>-->
		</xsl:call-template>
	</xsl:variable>
	<!--<xsl:variable name="rootName">
		<xsl:choose>
			<xsl:when test="exsl:node-set($questAncestors)/*[m8:holder( name() )=$user][not( */@type )]"><xsl:value-of select="name( exsl:node-set($questAncestors)/*[m8:holder( name() )=$user][not( */@type )][1] )"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$fact"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>-->
	<xsl:variable name="director" select="m8:director( $fact )"/>
	<xsl:variable name="directorName" select="$director"/>
	<xsl:variable name="leader" select="m8:director( $fact )"/>
	<xsl:variable name="parentName" select="name( exsl:node-set($parent)/*[last()] )"/>
	<xsl:variable name="grandName" select="name( exsl:node-set($parent)/*[last()-1] )"/>
	<xsl:variable name="typeName" select="name( exsl:node-set($parent)/*[last()]/* )"/>
	<xsl:param name="DirectoryRoot" select="'file:C:/Dropbox/xampp/htdocs/livecells/www'"/>
	<xsl:param name="mainServer" select="'www.m8data.com'"/>
	<xsl:param name="admin" select="'admin'"/>
	<xsl:param name="tempAuthor" select="/*/@tempAuthor"/>
	<xsl:param name="moment" select="/*/@moment"/>
	<xsl:param name="login" select="/*/@login"/>
	<xsl:param name="new_author" select="/*/@new_author"/>
	<xsl:param name="new_avatar" select="/*/@new_avatar"/>
	<!--<xsl:param name="object" select="/*/@object"/>-->
	<xsl:param name="m8mode" select="/*/@m8mode"/>
	<xsl:param name="referer" select="/*/@referer"/>
	<xsl:param name="message" select="/*/@message"/>
	<xsl:param name="add" select="/*/@add"/>
	<xsl:param name="del" select="/*/@del"/>
	<xsl:param name="Sec_of_New" select="100000"/>
	<xsl:param name="focus" select="/*/*/@focus"/>
	<xsl:param name="queryDeep" select="2"/>
	<xsl:param name="vf" select="'/value.xml'"/>
	<xsl:param name="if" select="'/index.xml'"/>
	<xsl:param name="ind" select="'/m8'"/>
	<xsl:param name="startIndex" select="m8:path( $fact, 'index' )"/>
	<xsl:param name="startPort" select="m8:port( $fact, $modifier )"/>
	<xsl:param name="factPort" select="m8:port( $fact )"/>
	<xsl:param name="startTypeName" select="name( $startPort/r/* )"/>
	<xsl:param name="ancestor-or-self">
		<xsl:message>	--- getAncestor --- </xsl:message>
		<xsl:call-template name="getAncestor">
			<xsl:with-param name="currentFactName" select="$fact"/>
		</xsl:call-template>
	</xsl:param>
	<xsl:param name="chief" select="name( exsl:node-set($ancestor-or-self)/*[*][last()] )"/>
	<!--<xsl:param name="chiefName" select="name( $superType )"/>-->
	<!--<xsl:variable name="factType" select="m8:path( $fact, $avatar, $parentName, 'port' )/r/*"/>-->
	<!--<xsl:variable name="factTypeName">
		<xsl:choose>
			<xsl:when test="$fact = 'n' ">i</xsl:when>
			<xsl:when test="starts-with($fact, 'n' )">
				<xsl:value-of select="name( m8:path( $fact, $author, $quest, 'port' )/r/* )"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring( $fact, 1, 1 )"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>-->
	<xsl:variable name="types" select="document( concat( $start/@planeRoot, 'm8/type.xml' ) )/*"/>
	<xsl:variable name="class" select="document( concat( $start/@planeRoot, 'm8/class.xml' ) )/*"/>
	<!-- ####  ЗНАКИ  ####
			&#215; - ×
			&#10060; - ❌
-->
	<xsl:param name="symbol_replace" select="'&#8644;'"/>
	<xsl:param name="symbol_up" select="'&#11014;'"/>
	<xsl:param name="symbol_del" select="'&#215;'"/>
	<xsl:param name="u2016" select="'&#8214;'" xml:lang="двойная вертикальная линия"/>
	<!-- ####  ЗНАКИ (END)  ####-->
	<!-- 
			Функции A
	-->
	<func:function name="m8:unic">
		<xsl:param name="rootNode"/>
		<xsl:param name="param"/>
		<func:result select="$rootNode/*[name()=$param]/*[count(../*)=1 or */@time=math:max( ../*/*/@time )]" xml:lang="проверка функцией max на случай ошибочного указания нескольких значений"/>
	</func:function>
	<func:function name="m8:dir">
		<xsl:param name="fact"/>
		<xsl:param name="quest"/>
		<xsl:choose>
			<xsl:when test="$quest">
				<func:result select="concat( 'm8/', substring( $fact, 1, 1 ), '/', $fact, '/', $quest )"/>
			</xsl:when>
			<xsl:when test="$fact">
				<func:result select="concat( 'm8/', substring( $fact, 1, 1 ), '/', $fact )"/>
			</xsl:when>
			<xsl:otherwise>
				<func:result select="'m8/n/n'"/>
			</xsl:otherwise>
		</xsl:choose>
	</func:function>
	<func:function name="m8:fact_color">
		<xsl:param name="fact"/>
		<func:result select="concat( 'color: #', translate( substring( $fact, 2, 3 ), '5qwertyuiopasdfghjklzxcvbnm', 'b1234567890abc1234567890abc' ) )"/>
	</func:function>
	<func:function name="m8:capital">
		<xsl:param name="fact"/>
		<xsl:param name="all"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="$all">
					<xsl:call-template name="uppercase">
						<xsl:with-param name="input" select="$fact"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="capitalLetter">
						<xsl:with-param name="input" select="$fact"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	<func:function name="m8:serialize">
		<xsl:param name="tree"/>
		<xsl:param name="title"/>
		<xsl:param name="size"/>
		<func:result>
			<code>
				<xsl:if test="$size">
					<xsl:attribute name="style"><xsl:value-of select="concat( 'font-size: ', $size )"/></xsl:attribute>
				</xsl:if>
				<div>
					<xsl:value-of select="$title"/>
				</div>
				<xsl:apply-templates select="exsl:node-set($tree)" mode="serialize"/>
			</code>
		</func:result>
	</func:function>
	<func:function name="m8:class">
		<xsl:param name="type"/>
		<func:result select="$types/@*[name()=$type]"/>
	</func:function>
	<func:function name="m8:type">
		<xsl:param name="class"/>
		<func:result select="name( $types/@*[.=$class] )"/>
	</func:function>
	<func:function name="m8:choese">
		<xsl:param name="first"/>
		<xsl:param name="second"/>
		<xsl:param name="third"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="$first and $first != 'BAD_NAME'">
					<xsl:value-of select="$first"/>
				</xsl:when>
				<xsl:when test="$second and $second != 'BAD_NAME'">
					<xsl:value-of select="$second"/>
				</xsl:when>	
				<xsl:when test="$third and $third != 'BAD_NAME'">
					<xsl:value-of select="$third"/>
				</xsl:when>								
			</xsl:choose>
		</func:result>
	</func:function>
	<func:function name="m8:choese_node">
		<xsl:param name="first"/>
		<xsl:param name="second"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="not($first)">
					<xsl:copy-of select="$second"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$first"/>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	<func:function name="m8:author">
		<xsl:param name="author"/>
		<xsl:choose>
			<xsl:when test="$author">
				<func:result select="concat( 'm8/author/', $author )"/>
			</xsl:when>
			<xsl:otherwise>
				<func:result select="'m8/n/n'"/>
			</xsl:otherwise>
		</xsl:choose>
	</func:function>
	<!-- 
			Функции B
	-->
	<func:function name="m8:path">
		<xsl:param name="level1"/>
		<xsl:param name="level2"/>
		<xsl:param name="level3"/>
		<xsl:choose>
			<xsl:when test="$level3">
				<func:result select="document( concat( $start/@planeRoot, m8:dir( $level1, $level2 ), '/', $level3, '.xml' ) )/*"/>
			</xsl:when>
			<xsl:when test="$level2">
				<func:result select="document( concat( $start/@planeRoot, m8:dir( $level1, $level2 ), '.xml' ) )/*"/>
			</xsl:when>
			<xsl:when test="$level1">
				<func:result select="document( concat( $start/@planeRoot, m8:dir( $level1 ), '.xml' ) )/*"/>
			</xsl:when>
			<xsl:otherwise>
				<func:result select="document( concat( $start/@planeRoot, 'm8/type.xml' ) )/*"/>
			</xsl:otherwise>
		</xsl:choose>
	</func:function>
	<func:function name="m8:file">
		<xsl:param name="level1"/>
		<xsl:param name="level2"/>
		<xsl:param name="level3"/>
		<xsl:choose>
			<xsl:when test="$level3">
				<func:result select="concat( $start/@prefix, m8:dir( $level1, $level2 ), '/', $level3 )"/>
			</xsl:when>
			<xsl:when test="$level2">
				<func:result select="concat( $start/@prefix, m8:dir( $level1, $level2 ) )"/>
			</xsl:when>
			<xsl:when test="$level1">
				<func:result select="concat( $start/@prefix, m8:dir( $level1 ) )"/>
			</xsl:when>
			<xsl:otherwise>
				<func:result select="concat( $start/@prefix, 'm8/type.xml' )"/>
			</xsl:otherwise>
		</xsl:choose>
	</func:function>
	<func:function name="m8:root">
		<xsl:param name="cFact"/>
		<xsl:param name="cModifier"/>
		<xsl:message>								== m8:root (fact: <xsl:value-of select="$cFact"/>; modifier: <xsl:value-of select="$cModifier"/>) ==</xsl:message>
		<func:result>
			<xsl:value-of select="$start/@prefix"/>
			<xsl:if test="$ctrl != $avatar">
				<xsl:value-of select="concat( 'a/', $ctrl, '/' )"/>
			</xsl:if>
			<xsl:if test="$cFact and ( $cFact!='n' or $cModifier )">
				<xsl:value-of select="concat( m8:dir( $cFact ), '/' )"/>
				<xsl:if test="$cModifier">
					<xsl:value-of select="concat(  '?modifier=', $cModifier )"/>
				</xsl:if>
			</xsl:if>
		</func:result>
	</func:function>
	<!-- 
			Функции C
	-->
	<func:function name="m8:value">
		<xsl:param name="fact"/>
		<xsl:param name="param"/>
		<xsl:param name="modifier"/>
		<func:result select="m8:path( $fact, 'value' )"/>
	</func:function>
	<func:function name="m8:index">
		<xsl:param name="fact"/>
		<func:result select="m8:path( $fact, 'index' )"/>
	</func:function>
	<func:function name="m8:role1">
		<xsl:param name="fact"/>
		<func:result select="m8:path( $fact, 'role1' )"/>
	</func:function>
	<func:function name="m8:quest">
		<xsl:param name="fact"/>
		<func:result select="m8:path( $fact, 'quest' )"/>
	</func:function>
	<func:function name="m8:port">
		<xsl:param name="cFact"/>
		<xsl:param name="cQuest"/>
		<!--<xsl:message>### функция вывода порта (cFact: <xsl:value-of select="$cFact"/>; cQuest: <xsl:value-of select="$cQuest"/>) ###</xsl:message>-->
		<xsl:choose>
			<xsl:when test="$cQuest and m8:path( $cFact, 'role1' )/*[name()=$cQuest]">
				<!--<xsl:message>	   найден порт в квесте</xsl:message>-->
				<func:result select="m8:path( $cFact, $cQuest, 'port' )"/>
			</xsl:when>
			<xsl:when test="not( $cQuest ) and m8:path( $cFact, 'role1' )/n">
				<!--<xsl:message>	   найден основной порт</xsl:message>-->
				<func:result select="m8:path( $cFact, 'n', 'port' )"/>
			</xsl:when>
			<xsl:otherwise>
				<func:result select="m8:path( 'n', 'n', 'port' )"/>
			</xsl:otherwise>
		</xsl:choose>
	</func:function>
	<func:function name="m8:link">
		<xsl:param name="factName"/>
		<xsl:param name="direction"/>
		<xsl:variable name="vektor">
			<xsl:choose>
				<xsl:when test="$direction=1">quest</xsl:when>
				<xsl:otherwise>role1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<func:result select="m8:path( $factName, $vektor )"/>
	</func:function>
	<!-- 
			Функции D 
	-->
	<func:function name="m8:director">
		<xsl:param name="fact"/>
		<!--<xsl:message>								== m8:director (fact: <xsl:value-of select="$fact"/>) ==</xsl:message>-->
		<func:result select="name( m8:unic( m8:port( $fact ), 'r' ) )"/>
		<!--<func:result select="name( m8:port( $fact )/r/* )"/>-->
	</func:function>
	<func:function name="m8:holder">
		<xsl:param name="fact"/>
		<xsl:message>								== m8:holder (fact: <xsl:value-of select="$fact"/>) ==</xsl:message>
		<!--<func:result select="m8:port( $fact )/r/*/*/@user"/>-->
		<func:result select=" m8:unic( m8:port( $fact ), 'r' )/*/@user"/>
	</func:function>
	<func:function name="m8:triple">
		<xsl:param name="fact"/>
		<xsl:param name="param"/>
		<xsl:param name="modifier"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="$param">
					<xsl:value-of select="name( m8:port( $fact, $modifier )/*[name()=$param]/*/* )"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name( m8:port( $fact )/r/*/* )"/>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	<func:function name="m8:param">
		<xsl:param name="fact"/>
		<xsl:param name="param"/>
		<xsl:param name="modifier"/>
		<func:result select="name( m8:unic( m8:port( $fact, $modifier ), $param ) )"/>
	</func:function>
	<!-- 
			Функции E 
	-->
	<func:function name="m8:title">
		<xsl:param name="fact"/>
		<xsl:param name="param"/>
		<xsl:param name="modifier"/>
		<!--<xsl:message>								== m8:title (fact: <xsl:value-of select="$fact"/>; param: <xsl:value-of select="$param"/>; modifier: <xsl:value-of select="$modifier"/>) ==</xsl:message>-->
		<func:result>
			<xsl:choose>
				<xsl:when test="$param">
					<!--<xsl:value-of select="m8:title( m8:param( $fact, $param, $modifier ) )"/>-->
					<xsl:call-template name="simpleName">
						<xsl:with-param name="name" select="m8:param( $fact, $param, $modifier )"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$fact">
					<xsl:call-template name="simpleName">
						<xsl:with-param name="name" select="$fact"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:comment/>
				</xsl:otherwise>
				<!--NULL_NAME-->
			</xsl:choose>
		</func:result>
	</func:function>
	<func:function name="m8:color">
		<xsl:param name="fact"/>
		<func:result select="m8:fact_color( m8:holder( $fact ) )"/>
	</func:function>
	<!-- 	-->
	<func:function name="m8:i">
		<xsl:param name="fact"/>
		<func:result select="m8:value( m8:param( $fact, 'i' ) )"/>
	</func:function>
	<func:function name="m8:d">
		<xsl:param name="fact"/>
		<func:result select="m8:value( m8:param( $fact, 'd' ) )"/>
	</func:function>
	<func:function name="m8:n">
		<xsl:param name="fact"/>
		<func:result select="m8:value( m8:param( $fact, 'n' ) )"/>
	</func:function>
	<!-- 	-->
	<func:function name="m8:ancestor-or-self">
		<xsl:param name="fact"/>
		<xsl:param name="chiefOnly"/>
		<xsl:variable name="ss">
			<xsl:call-template name="getAncestor">
				<xsl:with-param name="currentFactName" select="$fact"/>
				<xsl:with-param name="chiefOnly" select="$chiefOnly"/>
			</xsl:call-template>
		</xsl:variable>
		<func:result select="exsl:node-set( $ss )"/>
	</func:function>
	<!-- 
			Функции F 
	-->
	<func:function name="m8:sort">
		<xsl:param name="fact"/>
		<xsl:param name="quest"/>
		<func:result select="m8:title( name( m8:port( $fact, $quest )/*[name()=$sort]/* ) )"/>
	</func:function>
	<func:function name="m8:img">
		<xsl:param name="fact"/>
		<xsl:param name="modifier"/>
		<xsl:message>								== m8:img (fact: <xsl:value-of select="$fact"/>; modifier: <xsl:value-of select="$modifier"/>) ==</xsl:message>
		<xsl:variable name="chief" select="m8:chief( $fact )"/>
		<func:result select="concat( $start/@prefix, 'p/', m8:holder( $fact ), '/img/', m8:type( $chief ), '/', m8:title( $fact, $code, $modifier ) )"/>
	</func:function>
	<func:function name="m8:chief">
		<xsl:param name="fact"/>
		<func:result select="name( m8:ancestor-or-self( $fact, 1 )/*[1] )"/>
	</func:function>
	<func:function name="m8:status">
		<xsl:param name="fact"/>
		<func:result>
			<xsl:if test="m8:index( $fact )/object">
				<xsl:variable name="cChief" select="m8:chief( $fact )"/>
				<xsl:choose>
					<xsl:when test="$cChief !='n' and $cChief!=$fact">✿</xsl:when>
				</xsl:choose>
			</xsl:if>
		</func:result>
	</func:function>
	<func:function name="m8:copylist">
		<xsl:param name="factName"/>
		<func:result>
			<xsl:choose>
				<xsl:when test="m8:index( $factName )/object">
					<xsl:for-each select="m8:index( $factName )/object/*">
						<xsl:copy-of select="m8:copylist( name() )"/>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<n name="{$factName}">
						<xsl:for-each select="m8:port( $factName )/*">
							<xsl:attribute name="{m8:type( name() )}"><xsl:value-of select="m8:title( name( m8:unic( .., name() ) ) )"/></xsl:attribute>
						</xsl:for-each>
					</n>
				</xsl:otherwise>
			</xsl:choose>
		</func:result>
	</func:function>
	<!--
			Функции G 
//-->
	<func:function name="m8:relation">
		<xsl:param name="factName"/>
		<xsl:param name="targetName" xml:lang="принимается тип, а не класс"/>
		<xsl:param name="direct"/>
		<xsl:param name="secondName" xml:lang="принимается тип, а не класс"/>
		<xsl:param name="secondDirect" xml:lang="принимается тип, а не класс"/>
		
		<xsl:variable name="relation">
			<xsl:for-each select="m8:link( $factName, $direct )/*[m8:chief( name() )=m8:class($targetName)]">
				<xsl:sort select="m8:title( name(), 'd', $factName )" data-type="number"/>
				<xsl:variable name="relationName" select="name()"/>
				<xsl:element name="{$targetName}">
					<!--<xsl:attribute name="name"><xsl:value-of select="$relationName"/></xsl:attribute>-->
					<xsl:attribute name="factName"><xsl:value-of select="$factName"/></xsl:attribute>
					<xsl:attribute name="relationName"><xsl:value-of select="$relationName"/></xsl:attribute>
					<xsl:if test="m8:param( $relationName, 'd', $factName ) != 'r' ">
						<xsl:attribute name="d"><xsl:value-of select="m8:title( $relationName, 'd', $factName )"/></xsl:attribute>
					</xsl:if>
					<xsl:attribute name="holder"><xsl:value-of select="m8:holder( $relationName )"/></xsl:attribute>
					<xsl:if test="count( m8:port( $relationName, $factName )/*[name()!='d'] ) > 0">
						<modification>
							<!-- name="{$techlistName}"-->
							<xsl:for-each select="m8:port( $relationName, $factName )/*[name()!='d']">
								<xsl:element name="{m8:type( name() )}">
									<xsl:variable name="valueName" select="name( m8:unic( .., name() ) )"/>
									<xsl:element name="{$valueName}">
										<xsl:value-of select="m8:title( $valueName )"/>
									</xsl:element>
								</xsl:element>
							</xsl:for-each>
						</modification>
					</xsl:if>
				<!--	<xsl:variable name="copys" select="m8:copylist( $relationName )"/>-->
					<xsl:choose>
						<xsl:when test="$secondName">
							<xsl:for-each select="exsl:node-set( m8:copylist( $relationName ) )/*">
								<xsl:copy>
									<xsl:copy-of select="@*"/>
									
									<xsl:for-each select="m8:role1( @name )/*[name()!='n' and m8:chief( name() ) = $secondName]">
										<xsl:sort select="m8:title( name(), $depth )" data-type="number"/>
							<xsl:element name="{name()}">
								<xsl:attribute name="title"><xsl:value-of select="m8:title( name() )"/></xsl:attribute>
								<!--<xsl:attribute name="picture"><xsl:value-of select="$picture"/></xsl:attribute>-->
								<xsl:for-each select="m8:port( name() )/*|m8:port( m8:director(name()) )/*">
									
									<xsl:variable name="paramName" select="name()"/>
									<xsl:if test="$class/@*[name()=$paramName]">
										<xsl:element name="{$class/@*[name()=$paramName]}">
											<xsl:value-of select="m8:title( name(*) )"/>
											<!--<xsl:attribute name="title"></xsl:attribute>-->
											<!--<xsl:comment/>-->
										</xsl:element>
									</xsl:if>
								</xsl:for-each>
							</xsl:element>
						</xsl:for-each>
									<!--<xsl:copy-of select="m8:relation( @name, $secondName, $secondDirect )"/>-->
								</xsl:copy>
								<!--<xsl:copy-of select="."/>-->
							<!--	<dd>ss</dd>-->
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="m8:copylist( $relationName )"/>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:element>
			</xsl:for-each>
		</xsl:variable>
		<func:result select="exsl:node-set( $relation )"/>
	</func:function>
	<!--


	-->
	<xsl:template name="editParamOfPort">
		<xsl:param name="currentFact"/>
		<xsl:param name="currentModifier"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="objectElement"/>
		<xsl:param name="action"/>
		<xsl:param name="size"/>
		<xsl:param name="placeholder"/>
		<xsl:param name="hidden"/>
		<xsl:param name="inputType"/>
		<xsl:param name="inputInvalid"/>
		<xsl:param name="alertTitle"/>
		<xsl:param name="modifierName"/>
		<xsl:param name="questName"/>
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="titleSelect"/>
		<xsl:param name="ajaxMethod"/>
		<!--<xsl:variable name="selectedValue" select="$objectElement/*[name()=$predicateName]/*"/> or */@time = math:max( ../*/*/@time )  -->
		<xsl:variable name="selectedValue" select="m8:unic( $objectElement, $predicateName )"/>
		<!--<xsl:if test="name($selectedValue) = 'r' " xml:lang="add 2016-12-06"><xsl:attribute name="title">укажите здесь число больше нуля</xsl:attribute></xsl:if>-->
		<xsl:if test="not($sourceValue) and ( $objectElement/@message or $selectedValue/@message or $alertTitle)" xml:lang="только для текстовых инпутов для корректного отображения всплывающих сообщений">
			<xsl:attribute name="title"><xsl:choose xml:lang="2016-06-10: вносится наверх, а не в инпут т.к. при стилизации select2 сообщение нужно показывать не с инпута"><xsl:when test="$alertTitle"><xsl:value-of select="$alertTitle"/></xsl:when><xsl:when test="$objectElement/@message"><xsl:value-of select="$objectElement/@message"/></xsl:when><xsl:otherwise><xsl:value-of select="$selectedValue/@message"/></xsl:otherwise></xsl:choose></xsl:attribute>
		</xsl:if>
		<form id="editParamOfPort" selectedValue="{name($selectedValue)}" placeholder="{$placeholder}" inputInvalid="{$inputInvalid}"><!-- currentModifier="{$currentModifier}" questName="{$questName}"-->
			<xsl:attribute name="action"><xsl:choose><xsl:when test="$action"><xsl:value-of select="$action"/></xsl:when><xsl:otherwise><xsl:value-of select="m8:root( $fact )"/></xsl:otherwise></xsl:choose><!--<xsl:if test="$predicateName = 'n' ">/</xsl:if>			--></xsl:attribute>
			<xsl:if test="$predicateName = 'n' and not( $currentModifier )">
				<xsl:attribute name="ENCTYPE">multipart/form-data</xsl:attribute>
				<xsl:attribute name="method">POST</xsl:attribute>
			</xsl:if>
			<xsl:if test="$ajaxMethod='load'">
				<input type="hidden" id="refreshYes"/>
			</xsl:if>
			<!--<xsl:if test="$objectElement/@invalid or $selectedValue/@invalid" xml:lang="этот блок вероятно не нужен после добавления страхующего указания шага 2016-11-07 в выводе селекта теплозащиты">
				<input type="hidden" name="b1" value="{$rootName}"/>
				<input type="hidden" name="b2" value="{$shag}"/>
				<input type="hidden" name="b3" value="{$selectedValue/@invalid}{$objectElement/@invalid}"/>
			</xsl:if>-->
			<xsl:if test="$hidden">
				<xsl:for-each select="exsl:node-set($hidden)/*">
					<input type="hidden">
						<xsl:attribute name="name"><xsl:value-of select="name()"/></xsl:attribute>
						<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
					</input>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="( $currentModifier or $questName or $modifierName )" xml:lang="$modifier !='n' - нужен что бы можно было указывать n в квестах"><!--( $predicateName != 'n' or $modifier !='n' ) and -->
				<input type="hidden" name="modifier">
					<xsl:attribute name="value"><xsl:choose><xsl:when test="$questName"><xsl:value-of select="$questName"/></xsl:when><xsl:when test="$modifierName"><xsl:value-of select="$modifierName"/></xsl:when><xsl:when test="$currentModifier"><xsl:value-of select="$currentModifier"/></xsl:when><xsl:otherwise><xsl:value-of select="$modifier"/></xsl:otherwise></xsl:choose></xsl:attribute>
				</input>
				<!--<input type="hidden" name="quest" value="{$questName}"/>-->
			</xsl:if>
			<xsl:call-template name="inputParamOfPortPre">
				<xsl:with-param name="currentFact">
					<xsl:choose>
						<xsl:when test="$currentFact">
							<xsl:value-of select="$currentFact"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$fact"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
				<xsl:with-param name="currentModifier" select="$currentModifier"/>
<!--				<xsl:with-param name="currentModifier">
					<xsl:choose>
						<xsl:when test="$currentModifier">
							<xsl:value-of select="$currentModifier"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$modifier"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>-->
				<xsl:with-param name="inputType" select="$inputType"/>
				<xsl:with-param name="inputInvalid" select="$inputInvalid"/>
				<xsl:with-param name="size" select="$size"/>
				<xsl:with-param name="placeholder" select="$placeholder"/>
				<xsl:with-param name="questName" select="$questName"/>
				<xsl:with-param name="predicateName" select="$predicateName"/>
				<xsl:with-param name="selectedValue" select="$selectedValue"/>
				<xsl:with-param name="sourceValue" select="$sourceValue"/>
				<xsl:with-param name="sortSelect" select="$sortSelect"/>
				<xsl:with-param name="titleSelect" select="$titleSelect"/>
				<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
			</xsl:call-template>
			<xsl:if test="not( $currentModifier ) and $modifier != 'n'">
				<input type="hidden" name="m" value="{$modifier}"/>
			</xsl:if>
		</form>
	</xsl:template>
	<!--

	-->
	<xsl:template name="inputParamOfPortPre">
		<xsl:param name="currentFact"/>
		<xsl:param name="currentModifier"/>
		<xsl:param name="inputType"/>
		<xsl:param name="inputInvalid"/>
		<xsl:param name="size"/>
		<xsl:param name="placeholder"/>
		<xsl:param name="questName"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedValue"/>
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="titleSelect"/>
		<xsl:param name="option"/>
		<xsl:param name="ajaxMethod"/>
		<xsl:message>
			Запрос параметра <xsl:value-of select="$predicateName"/>
			selectedValue <xsl:value-of select="name($selectedValue)"/>
		</xsl:message>
		<xsl:choose>
			<xsl:when test="$sourceValue">
				<xsl:message>				Вывод параметра <xsl:value-of select="$predicateName"/> напрямую из входящего списка sourceValue</xsl:message>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="currentFact" select="$currentFact"/>
					<xsl:with-param name="currentModifier" select="$currentModifier"/>
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="inputInvalid" select="$inputInvalid"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="placeholder" select="$placeholder"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="$sourceValue"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="m8:port( $predicateName )/n and m8:n( $predicateName )/div" xml:lang="вывод списка из tsv-файла. Проверка дива нужна, т.к. файл может быть приложен любой">
				<!--$parentPredicateName,-->
				<xsl:message>				Вывод параметра <xsl:value-of select="$predicateName"/> списка из tsv-файла</xsl:message>
				<!--<xsl:variable name="currentListName" select="name( m8:port( $predicateName )/n/*)"/>-->
				<!--$parentPredicateName, -->
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="currentFact" select="$currentFact"/>
					<xsl:with-param name="currentModifier" select="$currentModifier"/>
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="inputInvalid" select="$inputInvalid"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="placeholder" select="$placeholder"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="m8:n( $predicateName )"/>
					<!-- m8:value( $currentListName )-->
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
					<xsl:with-param name="option" select="$option"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="( $predicateName='r' or $predicateName='modifier' ) and m8:index( $typeName )/object" xml:lang="вывод экземпляров типа 2016-07-23">
				<xsl:message>				Вывод параметров 'r' или 'modifier' списком экземпляров типа <xsl:value-of select="$typeName"/>
				</xsl:message>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="currentFact" select="$currentFact"/>
					<xsl:with-param name="currentModifier" select="$currentModifier"/>
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="inputInvalid" select="$inputInvalid"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="placeholder" select="$placeholder"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="m8:index( $typeName )/object"/>
					<!--<xsl:with-param name="sourceValue" select="m8:path( 'r', $actionAuthor, $fact, 'dock' )/*[name() != $fact]"/>-->
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
					<xsl:with-param name="option">
						<xsl:element name="option"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="m8:index( 'r' )/predicate/*[name()=$predicateName and name() != 'i' ] and $predicateName != 'n' " xml:lang="вывод экземпляров типа">
				<xsl:message>				Вывод параметра <xsl:value-of select="$predicateName"/> списком экземпляров типа</xsl:message>
				<xsl:variable name="list">
					<xsl:for-each select="m8:index( $predicateName )/object/*">
						<xsl:copy-of select="."/>
						<xsl:if test="m8:index( name() )/object/*">
							<xsl:copy-of select="m8:index( name() )/object/*"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="currentFact" select="$currentFact"/>
					<xsl:with-param name="currentModifier" select="$currentModifier"/>
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="inputInvalid" select="$inputInvalid"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="placeholder" select="$placeholder"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<!--<xsl:with-param name="sourceValue" select="m8:index( $predicateName )/object"/>-->
					<xsl:with-param name="sourceValue" select="exsl:node-set( $list )"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
					<xsl:with-param name="option">
						<xsl:element name="option"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>				Вывод параметра <xsl:value-of select="$predicateName"/> без селекта</xsl:message>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="currentFact" select="$currentFact"/>
					<xsl:with-param name="currentModifier" select="$currentModifier"/>
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="inputInvalid" select="$inputInvalid"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="placeholder" select="$placeholder"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:message>		Запрос параметра <xsl:value-of select="$predicateName"/> (END)
		</xsl:message>
	</xsl:template>
	<!--

	-->
	<xsl:template name="inputParamOfPort">
		<xsl:param name="currentFact"/>
		<xsl:param name="currentModifier"/>
		<xsl:param name="inputType"/>
		<xsl:param name="inputInvalid"/>
		<xsl:param name="size"/>
		<xsl:param name="placeholder"/>
		<xsl:param name="questName"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedValue"/>
		<!-- здесь должна прийти сама нода для обращения к ней без /*, но внутри должна быть нода активирующего трипла для удления -->
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="codeSelect"/>
		<xsl:param name="titleSelect"/>
		<xsl:param name="ajaxMethod"/>
		<xsl:param name="option"/>
		<xsl:param name="method"/>
		
		<xsl:variable name="params_of_quest" select="m8:port( $currentFact, $currentModifier )/*"/>
		<xsl:variable name="predicateParam" select="m8:value( name( m8:port( $predicateName )/d/* ) )"/>
		<xsl:message>		inputParamOfPort :: sourceValue: <xsl:copy-of select="count(exsl:node-set($sourceValue)/*)"/>
		</xsl:message>
		<xsl:choose>
			<!--
							ВЫВОД ЗАПРОСА ФАЙЛА
-->
			<xsl:when test="$predicateName = 'n' and not( $currentModifier )"><!--$modifier='n'-->
				<input type="file" name="file">
					<xsl:if test="not($ajaxMethod)">
						<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:if test="name($selectedValue) != 'r'">
					<!--<a href="{$start/@prefix}p/{ /{name($selectedValue)}/value.tsv">text</a>|-->
					<a href="{m8:file( name( $selectedValue ), 'value.xml' )}">xml</a>
				</xsl:if>
			</xsl:when>
			<!--
							ВЫВОД TEXTAREA
-->
			<xsl:when test="( $predicateName = 'd' and not( $currentModifier ) ) or $predicateParam/div[3]/span='textarea' ">
				<xsl:variable name="name">
					<xsl:apply-templates select="$selectedValue" mode="titleWord"/>
				</xsl:variable>
				<textarea name="{$predicateName}" placeholder="описание объекта">
					<xsl:choose>
						<xsl:when test="$predicateName = 'd'">
							<xsl:attribute name="cols">32</xsl:attribute>
							<xsl:attribute name="rows">3</xsl:attribute>
							<xsl:attribute name="placeholder">тип факта</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="cols">76</xsl:attribute>
							<xsl:attribute name="rows"><xsl:value-of select="count( m8:value( name( $selectedValue ) )/* ) + 4"/></xsl:attribute>
							<xsl:attribute name="placeholder">описание факта</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not($ajaxMethod)">
						<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
					</xsl:if>
					<xsl:if test="$name=''">
						<!--<xsl:attribute name="onfocus"><xsl:text>$(this).val('')</xsl:text></xsl:attribute>-->
						<xsl:text>	</xsl:text>
						<!--<xsl:comment>антидыра</xsl:comment>-->
					</xsl:if>
					<xsl:value-of select="$name"/>
				</textarea>
			</xsl:when>
			<!--
							ВЫВОД ИЗ СПИСКА DIV-ов
-->
			<xsl:when test="exsl:node-set($sourceValue)/div">
				<xsl:message>			Формирование селекта из tsv</xsl:message>
				<xsl:variable name="objectTitle">
					<xsl:choose>
						<xsl:when test="$selectedValue/span[1]">
							<xsl:value-of select="$selectedValue/span[1]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="$selectedValue" mode="simpleName"/>
							<!--titleWord-->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="titleSpan">
					<xsl:choose>
						<xsl:when test="$titleSelect">
							<xsl:value-of select="$titleSelect"/>
						</xsl:when>
						<xsl:otherwise>1</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="count(exsl:node-set($sourceValue)/*) = 2 and exsl:node-set($sourceValue)/*[1]/span=0 and exsl:node-set($sourceValue)/*[2]/span=1 and not(exsl:node-set($sourceValue)/*[1]/span[2])">
						<xsl:if test="name($selectedValue)='r1'">
							<input type="hidden" name="{$predicateName}" value="0"/>
						</xsl:if>
						<input type="checkbox" name="{$predicateName}" value="1">
							<xsl:if test="not($ajaxMethod)">
								<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
							</xsl:if>
							<xsl:if test="name($selectedValue)='r1'">
								<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
							</xsl:if>
						</input>
					</xsl:when>
					<xsl:when test="$inputType">
						<xsl:for-each select="exsl:node-set($sourceValue)/*">
							<xsl:sort select="span[$sortSelect]"/>
							<input class="input-category" type="{$inputType}" name="{$predicateName}" value="{span[1]}" id="{span[1]}">
								<xsl:for-each select="span">
									<xsl:attribute name="span{position()}"><xsl:value-of select="."/></xsl:attribute>
								</xsl:for-each>
								<xsl:if test="not($ajaxMethod)">
									<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
								</xsl:if>
								<xsl:if test="@description">
									<xsl:attribute name="description"><xsl:value-of select="@description"/></xsl:attribute>
								</xsl:if>
								<xsl:if test="span[1] = $objectTitle">
									<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
								</xsl:if>
							</input>
							<label class="list-group-item" for="{span[1]}">
								<xsl:value-of select="span[number($titleSpan)]"/>
							</label>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="valueNames">
							<xsl:for-each select="$params_of_quest[name()=$predicateName]/*">
								<xsl:element name="{name()}">
									<xsl:apply-templates select="." mode="titleWord"/>
								</xsl:element>
							</xsl:for-each>
						</xsl:variable>
						<select name="{$predicateName}" size="{$size}" objectTitle="{$objectTitle}">
							<xsl:attribute name="class"><xsl:choose><xsl:when test="exsl:node-set($sourceValue)/*[20]" xml:lang="для городов в калькуляторе TN например">custom-<xsl:value-of select="$ajaxMethod"/>-select</xsl:when><xsl:otherwise>simple-<xsl:value-of select="$ajaxMethod"/>-select</xsl:otherwise></xsl:choose></xsl:attribute>
							<xsl:if test="not($ajaxMethod)">
								<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
							</xsl:if>
							<xsl:copy-of select="$option"/>
							<xsl:for-each select="exsl:node-set($sourceValue)/*">
								<xsl:sort select="span[$sortSelect]"/>
								<!--span[$sortSelect]-->
								<xsl:variable name="currentVal" select="span[1]"/>
								<xsl:if test="1 or not(exsl:node-set($valueNames)/*[.=$currentVal]) or $currentVal=$objectTitle" xml:lang="требуется проверка необходимости">
									<option value="{span[1]}">
										<xsl:if test="span[1] = $objectTitle">
											<xsl:attribute name="selected"><xsl:value-of select="'selected'"/></xsl:attribute>
										</xsl:if>
										<xsl:value-of select="span[number($titleSpan)]"/>
									</option>
								</xsl:if>
							</xsl:for-each>
						</select>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!--
							ВЫВОД ИЗ СПИСКА НОД
-->
			<xsl:when test="exsl:node-set($sourceValue)/*">
				<!--[2] выводить селект нужно вероятно всегда когда есть список-->
				<xsl:message>				Формирование селекта из пришедшего списка нод</xsl:message>
				<xsl:choose>
					<xsl:when test="$inputType">
						<xsl:for-each select="exsl:node-set($sourceValue)/*">
							<xsl:sort select="@sort"/>
							<!--<xsl:value-of select="name($selectedValue)"/> = <xsl:value-of select="name()"/>-->
							<input class="input-radio" type="{$inputType}" name="{$predicateName}" value="{name()}" id="{name()}">
								<xsl:if test="not( $ajaxMethod )">
									<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
								</xsl:if>
								<xsl:if test="@description">
									<xsl:attribute name="description"><xsl:value-of select="@description"/></xsl:attribute>
								</xsl:if>
								<xsl:for-each select="span">
									<xsl:attribute name="span{position()}"><xsl:value-of select="."/></xsl:attribute>
								</xsl:for-each>
							</input>
							<label class="label-block" for="{name()}">
								<xsl:if test="@activity!=1">
									<xsl:attribute name="style">position: relative</xsl:attribute>
									<div style="position: absolute; right: 3px; top: 0; font-size: .6em; background-color: #B99; padding: 0 .5em; margin-right: .3em; letter-spacing: .2em; color: white ">не активно</div>
								</xsl:if>
								<xsl:if test="@imgPath">
									<img src="{@imgPath}/front.jpg" alt="{@code}" width="60"/>
								</xsl:if>
								<p>
									<xsl:value-of select="@title"/>
								</p>
							</label>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>					select-элемент</xsl:message>
						<select name="{$predicateName}">
							<xsl:if test="not($ajaxMethod)">
								<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="class"><xsl:choose><xsl:when test="exsl:node-set($sourceValue)/*[20]" xml:lang="для городов в калькуляторе TN например">custom-</xsl:when><xsl:otherwise>simple-</xsl:otherwise></xsl:choose><xsl:value-of select="$ajaxMethod"/><xsl:text>-select</xsl:text></xsl:attribute>
							<xsl:copy-of select="$option"/>
							<xsl:for-each select="exsl:node-set($sourceValue)/*">
								<xsl:sort select="m8:title( name() )"/>
								<!-- m8:title( name() )-->
								<xsl:variable name="valueName">
									<xsl:choose>
										<xsl:when test="m8:class( name() )">
											<xsl:value-of select="n/@name"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="name()"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:if test="not( $params_of_quest[ name() = $predicateName ]/*[name()=$valueName] ) or $valueName = name( $selectedValue )">
									<option value="{$valueName}">
										<xsl:if test="$valueName=name( $selectedValue )">
											<xsl:attribute name="selected"><xsl:value-of select="'selected'"/></xsl:attribute>
										</xsl:if>
										<xsl:variable name="title">
											<xsl:choose>
												<xsl:when test="@on_display">
													<xsl:value-of select="@on_display"/>
												</xsl:when>
												<xsl:when test="@title">
													<xsl:value-of select="@title"/>
												</xsl:when>
												<xsl:when test="n[not(@on_display)]/@i|n/@on_display" xml:lang="add 2016-12-06">
													<xsl:value-of select="n[not(@on_display)]/@i|n/@on_display"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:apply-templates select="." mode="simpleName"/>
													<!--titleWord-->
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<xsl:value-of select="$title"/>
									</option>
								</xsl:if>
							</xsl:for-each>
						</select>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!--
							ВЫВОД ТЕКСТОВОГО ПОЛЯ
-->
			<xsl:otherwise>
				<xsl:message>				inputParamOfPort :: Вывод текстового поля</xsl:message>
				<xsl:variable name="title">
					<xsl:apply-templates select="$selectedValue" mode="titleWord"/>
				</xsl:variable>
				<input type="text" name="{$predicateName}">						
					<xsl:if test="$placeholder">
						<xsl:attribute name="placeholder"><xsl:value-of select="$placeholder"/></xsl:attribute>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="$size">
							<xsl:attribute name="size"><xsl:value-of select="$size"/></xsl:attribute>
						</xsl:when>

						<xsl:otherwise>
							<xsl:variable name="length" select="string-length( $title )"/>
							<xsl:choose>
								<xsl:when test="$length > 70">
									<xsl:attribute name="size">70</xsl:attribute>
								</xsl:when>
								<xsl:when test="$length > 35">
									<xsl:attribute name="size"><xsl:value-of select="$length + 4"/></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="size"><xsl:value-of select="$length + 12"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not($ajaxMethod)">
						<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
					</xsl:if>
					<xsl:if test="$selectedValue/@invalid or $selectedValue/../../@invalid or name($selectedValue) = 'r' or $inputInvalid" xml:lang="last part add 2016-12-06">
						<xsl:attribute name="invalid"><xsl:value-of select="$selectedValue/@invalid"/><xsl:value-of select="$selectedValue/../../@invalid"/><xsl:value-of select="$inputInvalid"/></xsl:attribute>
					</xsl:if>
					<xsl:attribute name="value"><xsl:choose><xsl:when test="starts-with( name( $selectedValue ), 'r' )"><xsl:value-of select="translate( $title, '.', ',' )"/></xsl:when><xsl:otherwise><xsl:value-of select="$title"/></xsl:otherwise></xsl:choose></xsl:attribute>
				</input>
				<xsl:if test="starts-with( $title, 'http' )">
					<xsl:text> </xsl:text>
					<a href="{$title}">link</a>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template name="authorDef">
		<html>
			<head>
				<xsl:call-template name="TitleAndMisk"/>
			</head>
			<body>
				<xsl:if test="/*/*/@referer"> </xsl:if>
				<div style="text-align: center; padding: 2em; color: red">
					<xsl:value-of select="@history"/>
				</div>
				<table width="100%" cellpadding="6">
					<tr>
						<td valign="top" align="center">
							<h1>Вход</h1>
							<div>Укажите ваши логин и пароль</div>
							<form style="padding: 2em" action="{$start/@prefix}{$start/@m8path}" method="get">
								<input type="hidden" name="logout" value="1"/>
								<xsl:if test="$start/@error='no_user'">
									<div style="color: red">Пользователь с данным именем не зарегистрирован</div>
									<br/>
								</xsl:if>
						
						Логин: <input type="text" name="login"/>
								<!-- value="{$login}"-->
								<br/>
								<br/>
								<xsl:if test="$start/@error='bad_password'">
									<div style="color: red">Пароль указан не верно</div>
									<br/>
								</xsl:if>
								<xsl:if test="$start/@error='no_password'">
									<div style="color: red">Укажите пароль</div>
									<br/>
								</xsl:if>
					Пароль: <input type="password" name="password"/>
								<br/>
								<br/>
								<button type="submit">Войти</button>
							</form>
						</td>
						<td valign="top" align="center" style="display: none">
							<h1>Регистрация</h1>
							<form method="get" id="rs_first">
								<input type="hidden" name="author"/>
								<xsl:if test="@history='busy'">
									<div style="color: red">Имя уже занято </div>
									<!-- -->
								</xsl:if>
					Имя: <input type="text" name="new_author"/>
								<!---->
								<br/>(без пробелов латиницей)                                        <br/>
								<br/>
								<xsl:if test="@history and ( @history='bad_retype' or @history='no_password' )">
									<div style="color: red">
										<xsl:choose>
											<xsl:when test="@history='bad_retype'">Повторение пароля не совпало. Введите заново.</xsl:when>
											<xsl:when test="@history='no_password'">Задайте пароль</xsl:when>
										</xsl:choose>
									</div>
								</xsl:if>
					Пароль: <input type="password" name="new_password"/>
								<br/>
								<br/>
					Повтор: <input type="password" name="new_password2"/>
								<br/>
								<br/>
								<button type="submit" formaction="{$start/@prefix}">Регистрация</button>
								<br/>
							</form>
						</td>
					</tr>
				</table>
			</body>
		</html>
	</xsl:template>
	<!--

%%%%%%%%%%%%%%                    copyNamedType    			  %%%%%%%%%%%%%%                
	-->
	<xsl:template name="getNamedType">
		<xsl:param name="metterName"/>
		<!--<xsl:variable name="cType" select="$types/@*[name()=$metterName]"/>-->
		<xsl:variable name="cType" select="$metterName"/>
		<xsl:element name="{$cType}">
			<xsl:call-template name="copyNamedType">
				<xsl:with-param name="metterName" select="$cType"/>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="m8:index( $cType )/object/*">
					<children>
						<xsl:for-each select="m8:index( $cType )/object/*">
							<!--[name() != $constructionCalcName]-->
							<xsl:sort select="@time"/>
							<xsl:element name="{name()}">
								<xsl:call-template name="copyNamedType">
									<xsl:with-param name="metterName" select="name()"/>
								</xsl:call-template>
							</xsl:element>
						</xsl:for-each>
					</children>
				</xsl:when>
				<xsl:otherwise>_</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	<xsl:template name="copyNamedType">
		<xsl:param name="metterName"/>
		<xsl:apply-templates select="m8:port( $metterName )/*" mode="copyNamedType"/>
	</xsl:template>
	<!--  -->
	<xsl:template match="*" mode="copyNamedType">
		<xsl:choose>
			<xsl:when test="name() = 'd' or name()='n' or name()='r' ">
				<xsl:attribute name="{name()}"><xsl:value-of select="name(*)"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="name() = 'i' ">
				<xsl:attribute name="title" xml:lang="здесь нельзя брать из value/span, т.к. значением может быть и число"><xsl:apply-templates select="*" mode="simpleName"/></xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="dName" select="name( m8:port( name() )/d/* )"/>
				<xsl:variable name="namedType" select="m8:value( $dName )"/>
				<xsl:if test="starts-with( $namedType/div[2]/span, 'xsd:' )">
					<xsl:attribute name="{$namedType/div[1]/span}"><xsl:choose><xsl:when test="starts-with( name(*), 'n' )"><xsl:value-of select="name(*)"/></xsl:when><xsl:otherwise><xsl:apply-templates select="*" mode="simpleName"/></xsl:otherwise></xsl:choose></xsl:attribute>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
%%%%%%%%%%%%%%                    copyNamedType (END)   			  %%%%%%%%%%%%%%    
	-->
	<!--

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%                                                             %%%%%%%%%%%%%%
%%%%%%%%%%%%%%                    SERIALIZE    						%%%%%%%%%%%%%%                
%%%%%%%%%%%%%%                                                            %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	-->
	<xsl:template match="*" mode="serialize">
		<xsl:param name="continue"/>
		<div>
			<xsl:attribute name="style">padding-left: 2em; font-size: .95em; <xsl:if test="not($continue)">color: #<xsl:value-of select="substring( count(.//*|./@*) * 210, 1, 3 )"/></xsl:if></xsl:attribute>
			<xsl:text>&lt;</xsl:text>
			<xsl:value-of select="name(.)"/>
			<xsl:apply-templates select="@*" mode="serialize"/>
			<xsl:text>&gt;</xsl:text>
			<xsl:apply-templates mode="serialize">
				<xsl:with-param name="continue" select="1"/>
			</xsl:apply-templates>
			<xsl:text>&lt;/</xsl:text>
			<xsl:value-of select="name(.)"/>
			<xsl:text>&gt;</xsl:text>
		</div>
	</xsl:template>
	<xsl:template match="text()" mode="serialize">
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="@*" mode="serialize">
		<xsl:text> </xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>="</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	<!--

	-->
	<xsl:template name="footer">
		<!--<div style="position: fixed;  bottom: 1px; left: 1px; z-index: 1; color:gray">-</div>-->
		<xsl:if test="$adminMode and $start/@error">
			<div style="position: fixed; width:100%; text-align: center; bottom: 80px; z-index: 1; color:red" class="adminPanel">
				<xsl:value-of select="$start/@error"/>
			</div>
		</xsl:if>
		<xsl:if test="$adminMode and $start//@message">
			<div style="position: fixed; width:100%; text-align: center; bottom: 80px; z-index: 1; color: magenta" class="adminPanel">
				<xsl:value-of select="$start//@message"/>
			</div>
		</xsl:if>
		<xsl:if test="$user != 'guest' or $adminMode or $ctrl='formulyar'">
			<!-- or $start/@debug-->
			<div style="position: fixed;  bottom: 5px; left: 10px; z-index: 1; color:gray" class="adminPanel">
				<!--<a href="{$start/@prefix}" style="color:gray">START</a>
					<xsl:text> | </xsl:text>-->
				<xsl:comment/>
				<xsl:if test="1 or not( starts-with( $start/@user, 'user' ) )">
					<xsl:choose>
						<xsl:when test="$ctrl = 'formulyar' ">
							<a href="{$start/@prefix}a/{$avatar}/{ m8:dir( $fact ) }" style="color:orange">публичный раздел</a>
						</xsl:when>
						<!--, $quest-->
						<xsl:otherwise>
							<a href="{$start/@prefix}a/formulyar/{ m8:dir( $fact ) }" style="color:brown">aдминистративный раздел</a>
							<!--, $quest-->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</div>
			<div style="position: fixed; bottom: 5px; right: 10px; color: gray; z-index: 1" class="adminPanel">
				<xsl:if test="$user = $avatar">
					<div style="position: fixed;  bottom: 5px; left: 10px; z-index: 1; color:gray; display: none">
						<xsl:value-of select="$avatar"/>
					</div>
					<a href="{m8:root()}?reindex=1" style="color: gray">
						<xsl:value-of select="$start/@version"/>
					</a>
					<xsl:text> / </xsl:text>
					<xsl:if test="$start/@branche">
						<a href="{m8:root()}?reindex=2" style="color: gray">
							<xsl:value-of select="$start/@branche"/>
						</a>
						<xsl:text> </xsl:text>
						<xsl:value-of select="substring( $start/@head, 1, 4 )"/>
						<xsl:if test="$start/@dry">
							<sup style="color: red">&#160;new</sup>
						</xsl:if>
					</xsl:if>
					<xsl:text> | </xsl:text>
					<!--<xsl:text> &lt;- </xsl:text>-->
				</xsl:if>
				<xsl:if test="$start/@debug">
					<select name="ctrl" onchange="window.location.href=this.options[this.selectedIndex].value">
						<option/>
						<xsl:for-each select="document( concat( $start/@planeRoot, $start/@prefix, 'p/controller.xml' ) )/*/@*[name()!='formulyar' and name()!=$avatar]">
							<option value="{$start/@prefix}a/{name()}/{m8:dir( $fact )}">
								<xsl:value-of select="name()"/>
							</option>
						</xsl:for-each>
					</select>
					<xsl:text> | </xsl:text>
				</xsl:if>
				<xsl:if test="not( starts-with( $start/@user, 'user' ) )">
					<xsl:choose>
						<xsl:when test="$start/@debug">
							<a href="{m8:root( $fact )}?debug=switch" style="color: purple">debug on</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{m8:root( $fact )}?debug=switch" style="color: gray">debug off</a>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:text> | </xsl:text>
					<a href="{m8:file( $fact, $modifier, 'port.xml' )}" style="color:gray">
						<xsl:value-of select="$localtime"/>
					</a>
					<xsl:text> |  </xsl:text>
				</xsl:if>
				<span style="{ m8:fact_color( $user )}">
					<xsl:value-of select="$user"/>
				</span>
				<xsl:text> | </xsl:text>
				<xsl:choose>
					<xsl:when test="$user != 'guest' ">
						<a href="{m8:root( $fact )}?logout=true" style="color: red">выйти</a>
					</xsl:when>
					<xsl:otherwise>
						<!--<xsl:when test="$adminMode">-->
						<a href="{$start/@prefix}formulyar" style="color:blue">войти</a>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
