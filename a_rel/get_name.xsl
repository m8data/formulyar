<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:m8="http://m8data.com">
	<!--
//-->
	<xsl:template match="*[starts-with( name(), 'i' )]" mode="simpleName">
		<xsl:choose>
			<xsl:when test="count( m8:path( name() , 'value' )//span ) = 1">
				<xsl:value-of select="m8:path( name() , 'value' )//span"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="*[starts-with( name(), 'r' )]" mode="simpleName">
		<xsl:apply-templates select="." mode="number"/>
	</xsl:template>
	<xsl:template match="*[starts-with( name(), 'n' )]" mode="simpleName">
		<xsl:apply-templates select="m8:path( name(), $avatar, 'port' )/i/*" mode="simpleName"/>
	</xsl:template>
	<!--
//-->
	<xsl:template match="*" mode="titleWord_withType">
		<xsl:param name="currentAuthorName"/>
		<xsl:param name="currentQuestName"/>
		<xsl:apply-templates select="m8:path( name(), $avatar, 'port' )/r/*" mode="titleWord"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="." mode="titleWord">
			<xsl:with-param name="currentAuthorName" select="$currentAuthorName"/>
			<xsl:with-param name="currentQuestName" select="$currentQuestName"/>
		</xsl:apply-templates>
	</xsl:template>
	<!--
//-->
	<xsl:template match="@*" mode="titleWord_withType">
		<xsl:param name="currentAuthorName"/>
		<xsl:param name="currentQuestName"/>
		<xsl:apply-templates select="m8:path( ., $author, $fact, 'port' )/r/*" mode="titleWord"/>
		<xsl:text> </xsl:text>
		<xsl:apply-templates select="." mode="titleWord">
			<xsl:with-param name="currentAuthorName" select="$currentAuthorName"/>
			<xsl:with-param name="currentQuestName" select="$currentQuestName"/>
		</xsl:apply-templates>
	</xsl:template>
	<!--

//-->
	<xsl:template match="@*" mode="titleWord">
		<xsl:param name="currentAuthorName"/>
		<xsl:param name="currentQuestName"/>
		<xsl:variable name="element">
			<xsl:element name="{.}"/>
		</xsl:variable>
		<xsl:apply-templates select="exsl:node-set($element)" mode="titleWord">
			<xsl:with-param name="currentAuthorName" select="$currentAuthorName"/>
			<xsl:with-param name="currentQuestName" select="$currentQuestName"/>
		</xsl:apply-templates>
	</xsl:template>
	<!--


	-->
	<xsl:template match="*" mode="titleWord">
		<xsl:param name="currentAuthorName"/>
		<xsl:param name="currentQuestName"/>
		<xsl:variable name="prefix" select="substring(name(),1,1)"/>
		<!--<xsl:value-of select="name()"/>	
		<xsl:message terminate="yes">_</xsl:message>-->
		<xsl:choose>
			<xsl:when test="$prefix = 'i' ">
				<xsl:choose>
					<xsl:when test="name() = 'i' ">имя</xsl:when>
					<xsl:when test="m8:path( name(), 'value' )/*">
						<xsl:choose>
							<xsl:when test="count(m8:path( name(), 'value' )//span) > 16">
								<xsl:value-of select="name()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="m8:path( name(), 'value' )/*">
									<xsl:for-each select="span">
										<xsl:value-of select="."/>
										<xsl:if test="position() != last()">
											<xsl:text>	</xsl:text>
										</xsl:if>
									</xsl:for-each>
									<xsl:if test="position() != last()">
										<xsl:text>
</xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!--<pre></pre>[список]-->
					<xsl:when test="m8:path( name(), 'value' )//span">
						<xsl:value-of select="m8:path( name(), 'value' )/div/span"/>
						<!--substring( , 0, 140 )-->
					</xsl:when>
					<xsl:otherwise>
						файл с значением поврежден! <!-- это на тот случай если по ошибке исчез или не записался value.xml -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$prefix = 'r' ">
				<xsl:choose>
					<xsl:when test="name() = 'r' "/>
					<!--<xsl:text> </xsl:text>-->
					<xsl:otherwise>
						<xsl:value-of select="translate( substring-after( name(), 'r' ), '_', ',' )"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$prefix = 'd' ">
				<xsl:choose>
					<xsl:when test="name() = 'd' ">обстоятельства</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="m8:path( name(), 'value' )/*">
							<xsl:sort select="@role"/>
							<xsl:apply-templates select="." mode="titleWord"/>
							<xsl:if test="position() != last()">::</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
					<!--//-->
				</xsl:choose>
			</xsl:when>
			<xsl:when test="name() = 'n' ">структура</xsl:when>
			<xsl:when test="1 and $currentQuestName and $currentAuthorName and m8:path( name(), $currentAuthorName, $currentQuestName, 'port' )/i">
				<xsl:message>Попытка найти имя в потру текущего автора</xsl:message>
				<xsl:apply-templates select="m8:path( name(), $currentAuthorName, $currentQuestName, 'port' )/i/*" mode="titleWord"/>
				<!--	<xsl:variable name="nameValueFromPort" select="name( m8:path( '/m8/', @type, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' )/name/* )"/>
				<xsl:choose>
					<xsl:when test="starts-with( $nameValueFromPort, 'l' )"><xsl:value-of select="m8:path( '/m8/d/', $nameValueFromPort, '/value.xml' )"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$nameValueFromPort"/></xsl:otherwise>
				</xsl:choose>-->
			</xsl:when>
			<xsl:when test="1 and m8:path( name(), $author, $quest, 'port' )/i">
				<xsl:message>Попытка найти имя в потру текущего автора</xsl:message>
				<xsl:apply-templates select="m8:path( name(), $author, $quest, 'port' )/i/*" mode="titleWord"/>
				<!--	<xsl:variable name="nameValueFromPort" select="name( m8:path( '/m8/', @type, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' )/name/* )"/>
				<xsl:choose>
					<xsl:when test="starts-with( $nameValueFromPort, 'l' )"><xsl:value-of select="m8:path( '/m8/d/', $nameValueFromPort, '/value.xml' )"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$nameValueFromPort"/></xsl:otherwise>
				</xsl:choose>-->
			</xsl:when>
			<xsl:when test="1 and m8:path( name(), $author, 'port' )/i">
				<xsl:message>Попытка найти имя в потру аватар-автора</xsl:message>
				<xsl:apply-templates select="m8:path( name(), $author, 'port' )/i/*" mode="titleWord"/>
			</xsl:when>
			<xsl:when test="0 and m8:path( name(), $avatar, 'port' )/i">
				<xsl:message>Попытка найти имя в потру аватар-автора (!! на этом выводе виснет по какой-то причине, видимо уходит в цикл !!)</xsl:message>
				<xsl:apply-templates select="m8:path( name(), $avatar, 'port' )/i/*" mode="titleWord"/>
			</xsl:when>
			<xsl:when test="1 and m8:path( name(), 'subject_r' )/*/*/*">
				<xsl:if test="not($currentQuestName)">
					<xsl:variable name="parentFact" select="m8:path( name(), 'subject_r' )/*/*[1]"/>
					<xsl:variable name="parentFactName" select="name($parentFact)"/>
					<xsl:apply-templates select="m8:path( name(), $avatar, $parentFactName, 'port' )/r/*" mode="titleWord"/>
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="substring (name(), 13)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="name()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*" mode="number">
		<xsl:value-of select="translate( substring( name(), 2 ), '_', '.' )"/>
	</xsl:template>
	<xsl:template match="@*" mode="number">
		<xsl:value-of select="translate( substring( ., 2 ), '_', '.' )"/>
	</xsl:template>
	<!--

	-->
	<xsl:template name="getParent">
		<xsl:param name="currentFactName"/>
		<xsl:variable name="parentFactName" select="name( m8:path( $currentFactName, 'subject_r' )/*/*[1] )"/>
		<xsl:variable name="parentAuthorName" select="name( m8:path( $currentFactName, 'subject_r' )/* )"/>
		<xsl:message>
			================ getParent ================
			currentFactName: <xsl:value-of select="$currentFactName"/>
			parentFactName: <xsl:value-of select="$parentFactName"/>
			parentAuthorName: <xsl:value-of select="$parentAuthorName"/>
		</xsl:message>
		<xsl:choose>
			<xsl:when test="$parentFactName = $currentFactName">
				<xsl:variable name="parentTypeName" select="name( m8:path( $parentFactName, $parentAuthorName, 'port' )/r/* )"/>
				<xsl:message>			Обнаружен независимый факт 
				parentTypeName: <xsl:value-of select="$parentTypeName"/>
				parentTypeQuest: <xsl:value-of select="name( m8:path( $parentTypeName, 'subject_r' )/*/* )"/>
				</xsl:message>
				<xsl:choose>
					<xsl:when test="name( m8:path( $parentTypeName, 'subject_r' )/*/* ) = $parentTypeName">
						<xsl:message>			Вывод результата:  <xsl:value-of select="$currentFactName"/>
						</xsl:message>
						<xsl:value-of select="$currentFactName"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="getParent">
							<xsl:with-param name="currentFactName" select="$parentTypeName"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getParent">
					<xsl:with-param name="currentFactName" select="$parentFactName"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template name="uppercase">
		<xsl:param name="input"/>
		<xsl:value-of select="translate($input,
           'йцукенгшщзхъфывапролджэячсмитьбю',  
           'ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ')"/>
	</xsl:template>
	<!--

	-->
	<xsl:template match="*|@*" mode="capitalLetter">
		<xsl:call-template name="capitalLetter">
			<xsl:with-param name="input" select="."/>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="capitalLetter">
		<xsl:param name="input"/>
		<xsl:call-template name="uppercase">
			<xsl:with-param name="input" select="substring($input, 1, 1)"/>
		</xsl:call-template>
		<xsl:value-of select="substring($input, 2)"/>
	</xsl:template>
	<!--

	-->
</xsl:stylesheet>
