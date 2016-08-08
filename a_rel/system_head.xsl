<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com">
	<xsl:param name="DirectoryRoot" select="'file:C:/Dropbox/xampp/htdocs/livecells/www'"/>
	<xsl:param name="mainServer" select="'www.m8data.com'"/>
	<xsl:param name="admin" select="'admin'"/>
	<!--<xsl:param name="ctrl" select="/*/@ctrl"/>
	<xsl:param name="group" select="/*/@user"/>-->
	<xsl:param name="tempAuthor" select="/*/@tempAuthor"/>
	<xsl:param name="moment" select="/*/@moment"/>
	<xsl:param name="login" select="/*/@login"/>
	<xsl:param name="new_author" select="/*/@new_author"/>
	<xsl:param name="new_avatar" select="/*/@new_avatar"/>
	<!--<xsl:param name="password" select="/*/@password"/>
	<xsl:param name="new_password" select="/*/@new_password"/>
	<xsl:param name="new_password2" select="/*/@new_password2"/>-->
	<!--<xsl:param name="questID" select="/*/@questID"/>-->
	<xsl:param name="object" select="/*/@object"/>
	<!--<xsl:param name="questID" select="/*/@questID"/>
	<xsl:param name="questFile" select="concat( '/m8/n0/', $quest, '/', $author, '/index.xml' )"/>
	<xsl:param name="script" select="$questID"/>
	<xsl:param name="regScript" select="$questID"/>-->
	<xsl:param name="m8mode" select="/*/@m8mode"/>
	<xsl:param name="referer" select="/*/@referer"/>
	<xsl:param name="message" select="/*/@message"/>
	<xsl:param name="add" select="/*/@add"/>
	<xsl:param name="del" select="/*/@del"/>
	<xsl:param name="Sec_of_New" select="100000"/>
	<xsl:param name="focus" select="/*/*/@focus"/>
	<!-- <xsl:param name="author" select="/*/*/@author"/>
	<xsl:param name="arbitr" select="/*/*/@arbitr"/>
	<xsl:param name="usrPath" select="concat('/', $avatar, '/', $arbitr, '/', $author)"/>
	<xsl:param name="view" select="/*/*/@view"/> -->
	<!--<xsl:param name="authorMultID" select="document(concat('/m8/r0/', $author, '/mult'))/*"/>
	<xsl:param name="avatarMultID" select="document(concat('/m8/r0/', $avatar, '/mult'))/*"/>-->
	<!--<xsl:param name="deep" select="2"/>-->
	<xsl:param name="queryDeep" select="2"/>
	<xsl:param name="vf" select="'/value.xml'"/>
	<xsl:param name="if" select="'/index.xml'"/>
	<xsl:param name="ind" select="'/m8'"/>
	<xsl:variable name="startPort" select="m8:path( $fact, $author, $quest, 'port' )"/>
	<xsl:param name="startTypeName" select="name( $startPort/r/* )"/>

	<!--<xsl:param name="layer2" select="'gen'"/>
	i7118132368377864911 - да

	 -->
	<xsl:template match="/">
		<xsl:message terminate="no">interface match="/"</xsl:message>
		<!--<script type="javascript">alert('dd');</script> onclick="alert(source)"

		<xsl:if test="*/error">
			<div style="position: absolute; bottom: 40px; right: 10px" title="{*/error/@message}">E</div>
		</xsl:if>-->
		<xsl:choose>
			<xsl:when test="m8:path( $fact, $author, $quest, 'port' )">
				<!--<xsl:value-of select="concat(  '/m8/', substring($fact,1,1), '/', $fact, '/', $author, '/', $quest, '/port.xml' ) "/>-->
				<xsl:apply-templates select="m8:path( $fact, $author, $quest, 'port' )"/>
			</xsl:when>
<!--			<xsl:when test="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/index.xml' ))/*/role/role1 and document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/role1.xml' ))/*/*[name()=$author]">
				<xsl:variable name="cQest" select="name(document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/role1.xml' ))/*/*[name()=$author]/*)"/>
				<xsl:value-of select="concat( '/m8/', substring($fact,1,1), '/', $fact, '/role1.xml' ) "/>
			</xsl:when>-->
			<xsl:otherwise>
				<xsl:apply-templates select="m8:path( 'n', 'admin', 'port' )"/>
			</xsl:otherwise>
			<!--<html><body><xsl:value-of select="$localtime"/>: квест не задан</body></html>-->
		</xsl:choose>
	</xsl:template>
	<!--


	-->
	<xsl:template match="port">
		<html>
			<head>
				<!--<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/> это лишне, cgi и так все задает верно
				<script src="/bower_components/platform.js"></script>
				<link rel="import" href="/bower_components/polymer/polymer.html"/>
				<script type="text/javascript" src="/system/a/js/book/jquery.min.js"/>-->
				<!--<script type="text/javascript" src="/system/a/js/jquery-2.1.3.js"/>
				<script type="text/javascript" src="/system/a/js/form.js"/>
				<script type="text/javascript">var source = "";
				</script>-->
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
				<!-- onload="onloadBody()"-->
				<xsl:if test="$message">
					<div style="position: absolute; bottom: 25px; right: 400px">
						<xsl:value-of select="$message"/>
					</div>
				</xsl:if>
				<div style="width: 100%" align="center">
					<!-- background: gray -->
					<div class="page">
						<xsl:call-template name="head"/>
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
					<a href="/system/" style="color: red; ">сменить группу</a>
					<!--<a href="/{$avatar}/" style="color: red; ">сменить аватар</a>-->
				</div>
			</xsl:if>
			<div style="float: right">
				<xsl:choose>
					<xsl:when test="$user='guest'">
						<a href="/system/?author=" style="color: #CFC">войти</a>
					</xsl:when>
					<xsl:otherwise>
						<span style="color: yellow">
							<xsl:value-of select="$user"/>
						</span>
						<xsl:value-of select="' '"/>
						<a href="/system/?author=" style="color: red">выйти</a>
						<!-- &amp;tempAvatar=system -->
						<!--<span style="color: yellow">Для участия -&gt;  </span>-->
						<!-- &amp;tempAvatar=system -->
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<br clear="all"/>
		</div>
	</xsl:template>
	<!--


	-->
</xsl:stylesheet>
