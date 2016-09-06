<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com">
	<xsl:param name="DirectoryRoot" select="'file:C:/Dropbox/xampp/htdocs/livecells/www'"/>
	<xsl:param name="mainServer" select="'www.m8data.com'"/>
	<xsl:param name="admin" select="'admin'"/>
	<xsl:param name="tempAuthor" select="/*/@tempAuthor"/>
	<xsl:param name="moment" select="/*/@moment"/>
	<xsl:param name="login" select="/*/@login"/>
	<xsl:param name="new_author" select="/*/@new_author"/>
	<xsl:param name="new_avatar" select="/*/@new_avatar"/>
	<xsl:param name="object" select="/*/@object"/>
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
	<xsl:variable name="startIndex" select="m8:path( $fact, 'index' )"/>
	<xsl:variable name="startPort" select="m8:path( $fact, $author, $quest, 'port' )"/>
	<xsl:param name="startTypeName" select="name( $startPort/r/* )"/>

	<!--<xsl:param name="layer2" select="'gen'"/>
	i7118132368377864911 - да

	 -->
	<xsl:template match="/">
		<xsl:message terminate="no">interface match="/"</xsl:message>
		<xsl:variable name="factIndex" select="m8:path( $fact, 'index')"/>
		<xsl:choose>
			<xsl:when test="$start/@user='guest' and $start/@mission='formulyar'"><!-- or $start/@ipath='a' -->
			<!--<xsl:when test="$start/@path = '/m8' or $start/@path=concat( '/', $ctrl, '/m8' ) or $start/@path = '/formulyar' or $start/@path = '/a/formulyar' ">-->
				<xsl:call-template name="authorDef"/>
			</xsl:when>
			<xsl:when test="$factIndex/role/role1">
				<xsl:apply-templates select="m8:path( $fact, $author, $quest, 'port' )"/>
			</xsl:when>
			<xsl:when test="$factIndex/role/role2">
				<xsl:apply-templates select="m8:path( $fact, $author, $quest, 'dock' )"/>
			</xsl:when>		
			<xsl:when test="$factIndex/role/role3">
				<xsl:apply-templates select="m8:path( $fact, $author, $quest, 'terminal' )"/>
			</xsl:when>		
			<xsl:otherwise>
				<xsl:apply-templates select="m8:path( 'n', 'admin', 'port' )"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--


	-->
	<xsl:template match="port|terminal">
		<html>
			<head>
				<xsl:call-template name="TitleAndMisk"/>
				<xsl:call-template name="Head2"/>
				<style>a {
				color: blue;
				text-decoration: none;
				}
				a:active {
					color: blue;
					text-decoration: none;
				}
				a:link {
					color: blue;
					text-decoration: none;
				}
				a:visited {
					color: blue;
					text-decoration: none;
				}
				a:focus {
					color: blue;
					text-decoration: none;
				}
				a:hover {
					color: blue;
					text-decoration: none;
				}
				div.page {
					background: white
				}

				</style>
			</head>
			<body style="padding: 0; margin: 0; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 0.8em;  text-align: center">
				<!--background: gray; -->
				<xsl:if test="$message">
					<div style="position: absolute; bottom: 25px; right: 400px">
						<xsl:value-of select="$message"/>
					</div>
				</xsl:if>
				<div style="width: 100%" align="center">
					<!-- background: gray -->
					<div class="page">
						<!--<xsl:call-template name="head"/>-->
						<xsl:call-template name="startBody"/>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
	<!--


	-->
	<xsl:template match="@*">
		<xsl:copy-of select="."/>
	</xsl:template>
	<!--


	-->
	<xsl:template name="head">
		<div style="position: fixed; top: 0px; background: black; text-align: center; width: 100%; ">
			<xsl:if test="document( '/avatar.xml' )/*/*[2]">
				<div style="float: left">
					<a href="/formulyar/" style="color: red; ">сменить группу</a>
				</div>
			</xsl:if>
			<div style="float: right">
				<xsl:choose>
					<xsl:when test="$user='guest'">
						<a href="/formulyar/?author=" style="color: #CFC">войти</a>
					</xsl:when>
					<xsl:otherwise>
						<span style="color: yellow">
							<xsl:value-of select="$user"/>
						</span>
						<xsl:value-of select="' '"/>
						<a href="/m8/?author=" style="color: red">выйти</a>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<br clear="all"/>
		</div>
	</xsl:template>
	<!--


	-->
</xsl:stylesheet>
