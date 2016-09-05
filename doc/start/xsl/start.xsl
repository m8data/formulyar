<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com" xmlns:func="http://exslt.org/functions" extension-element-prefixes="func">
	<xsl:include href="../../formulyar/xsl/system_form.xsl"/>
	<!--

	-->
	<xsl:template match="/">
		<html>
			<head>
				<title>Старт</title>
				<link rel="icon" type="image/ico" href="/p/{$avatar}/img/favicon.ico" />
			</head>
			<body>
				<div style="width: 800px; margin: 1em auto">
				<h1>Домашняя страница сайта</h1>
				<xsl:apply-templates select="document(  concat( $start/@DOCUMENT_ROOT, '/', $authDir, '/start/author.xml' ) )/*" mode="baseReport"/>
				<xsl:call-template name="footer"/>
				</div>
			</body>
		</html>
	</xsl:template>
	<xsl:template match="author" mode="baseReport">
		<xsl:variable name="typeNode">
			<xsl:for-each select="*">
				<xsl:sort select="@time"/>
				<xsl:variable name="tripleDiv" select="m8:path( name(), 'value' )/div"/>
				<xsl:copy>
					<xsl:attribute name="span1"><xsl:value-of select="$tripleDiv/span[1]"/></xsl:attribute>
					<xsl:attribute name="span2"><xsl:value-of select="$tripleDiv/span[2]"/></xsl:attribute>
					<xsl:attribute name="span3"><xsl:value-of select="$tripleDiv/span[3]"/></xsl:attribute>
					<xsl:for-each select="*">
						<xsl:copy>
							<xsl:copy-of select="@time"/>
							<xsl:copy-of select="@user"/>
						</xsl:copy>
					</xsl:for-each>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each select="exsl:node-set($typeNode)/*[ @span2='r' and @span3='n' ]">
			<xsl:variable name="typeName" select="@span3"/>
			<h3>
				<xsl:value-of select="position()"/>) <xsl:apply-templates select="@span1" mode="simpleName"/>
			</h3>
			<xsl:variable name="objective">
				<xsl:apply-templates select="*" mode="childs_baseReport">
					<xsl:with-param name="level" select="0"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:apply-templates select="exsl:node-set($objective)/*" mode="serialize"/>
		</xsl:for-each>
	</xsl:template>
	<!--
	-->
	<xsl:template match="*" mode="childs_baseReport">
		<xsl:param name="level"/>
		<xsl:variable name="cMetter" select="../@span1"/>
		<xsl:variable name="cQuest" select="name()"/>
		<xsl:element name="{$cMetter}">
			<xsl:if test="$level > 0">
				<xsl:attribute name="type"><xsl:apply-templates select="../@span3" mode="simpleName"/></xsl:attribute>
			</xsl:if>
			<xsl:for-each select="/*[ @span2!='r' and @span1=$cMetter ]/*[name()=$cQuest]">
				<xsl:sort select="../@span2"/>
				<xsl:variable name="attrName">
					<xsl:choose>
						<xsl:when test="m8:path( ../@span2, $avatar, 'port' )/d">
							<xsl:value-of select="m8:path( name( m8:path( ../@span2, $avatar, 'port' )/d/* ), 'value' )/div[1]/span"/>
						</xsl:when>
						<xsl:when test="../@span2 and ../@span2='i'">
							<xsl:text>title</xsl:text>
						</xsl:when>
						<xsl:when test="../@span2">
							<xsl:value-of select="../@span2"/>
						</xsl:when>
						<xsl:otherwise>BAD_NAME</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:attribute name="{$attrName}"><xsl:choose><xsl:when test="../@span3=''">ТИП</xsl:when><xsl:otherwise><xsl:apply-templates select="../@span3" mode="simpleName"/></xsl:otherwise></xsl:choose></xsl:attribute>
			</xsl:for-each>
			<xsl:choose>
				<xsl:when test="$level > 6">error</xsl:when>
				<xsl:otherwise>
					<!--<xsl:if test="/*[ @span1!=$cMetter and @span2!='r' ]/*[name()=$cMetter]">
						<RELATE>
							<xsl:for-each select="/*[ @span1!=$cMetter and @span2!='r' ]/*[name()=$cMetter]">
								<xsl:copy-of select=".."/>
							</xsl:for-each>
						</RELATE>
					</xsl:if>-->
					<xsl:if test="/*[ @span1!=$cMetter and @span2='r' ]/*[name()=$cMetter]">
						<LOCAL>
							<xsl:apply-templates select="/*[ @span1!=$cMetter and @span2='r' ]/*[name()=$cMetter]" mode="childs_baseReport">
								<xsl:with-param name="level" select="$level+1"/>
							</xsl:apply-templates>
						</LOCAL>
					</xsl:if>
					<xsl:if test="/*[ @span2='r' and @span3=$cMetter ]/*[name()=../@span1]">
						<GLOBAL>
							<xsl:apply-templates select="/*[ @span2='r' and @span3=$cMetter ]/*[name()=../@span1]" mode="childs_baseReport">
								<xsl:with-param name="level" select="$level+1"/>
							</xsl:apply-templates>
						</GLOBAL>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	<!--

	-->
</xsl:stylesheet>
