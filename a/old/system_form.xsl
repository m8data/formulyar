<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common">
	<!--
-->
	<xsl:variable name="da" select="name( document( '/m8/i/i7118132368377864911/role3.xml' )/*/*/*/* )"/>
	<!--
	информация по стартовому xml (здесь излишне читать порт, т.к. иногда он нужен)-->
	<xsl:variable name="start" select="/*"/>
	<xsl:variable name="ctrl" select="$start/@ctrl"/>
	<xsl:variable name="fact" select="$start/@fact"/>
	<xsl:variable name="author" select="$start/@author"/>
	<xsl:variable name="avatar" select="$start/@avatar"/>
	<xsl:variable name="quest" select="$start/@quest"/>
	<xsl:variable name="xsStartID" select="concat( '/m8/', substring($fact,1,1), '/', $fact )"/>
	<xsl:variable name="sStartID" select="concat( $xsStartID, '/', $author, '/', $avatar, '/', $quest )"/>
	<xsl:variable name="startID" select="concat( '/', $ctrl, $sStartID )"/>
	<xsl:variable name="group" select="$start/@group"/>
	<xsl:variable name="user" select="$start/@user"/>
	<xsl:variable name="time" select="$start/@time"/>
	<xsl:variable name="localtime" select="$start/@localtime"/>
	<!--<xsl:variable name="startPort" select="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/', $author, '/', $avatar, '/', $quest, '/port.xml' ) )/*"/>	-->
	<!--


//-->
	<xsl:template match="*" mode="titleWord_withType">
		<xsl:param name="currentAuthorName"/>
		<xsl:param name="currentQuestName"/>
		<xsl:variable name="prefix" select="substring(name(),1,1)"/>
		<xsl:apply-templates select="document ( concat( '/m8/', $prefix, '/', name(), '/', $avatar, '/', $avatar, '/',  name(), '/port.xml' ) )/*/r/*" mode="titleWord"/>
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
		<xsl:variable name="prefix" select="substring(.,1,1)"/>
		<xsl:apply-templates select="document ( concat( '/m8/', $prefix, '/', ., '/', $author, '/', $avatar, '/', $fact, '/port.xml' ) )/*/r/*" mode="titleWord"/>
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
		<xsl:choose>
			<xsl:when test="$prefix = 'i' ">
				<xsl:choose>
					<xsl:when test="name() = 'i' ">имя</xsl:when>
					<xsl:when test="document ( concat( '/m8/i/', name(), '/value.xml' ) )/*/*">
						<xsl:choose>
							<xsl:when test="document ( concat( '/m8/i/', name(), '/value.xml' ) )/*/*/span">список <xsl:value-of select="name()"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="document ( concat( '/m8/i/', name(), '/value.xml' ) )/*/*">
									<xsl:value-of select="text()"/>
									<xsl:if test="position() != last()">
										<xsl:text>
</xsl:text>
									</xsl:if>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!--<pre></pre>[список]-->
					<xsl:when test="document ( concat( '/m8/i/', name(), '/value.xml' ) )/*/text()">
						<xsl:value-of select="document ( concat( '/m8/i/', name(), '/value.xml' ) )/*"/>
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
					<xsl:when test="name() = 'd' ">d</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="document(concat('/m8/d/', name(), '/value.xml'))/*/*">
							<xsl:sort select="@role"/>
							<xsl:apply-templates select="." mode="titleWord"/>
							<xsl:if test="position() != last()">::</xsl:if>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="name() = 'n' ">структура</xsl:when>
			<xsl:when test="$currentQuestName and $currentAuthorName and document( concat( '/m8/', $prefix, '/', name(), '/', $currentAuthorName, '/', $avatar, '/', $currentQuestName, '/port.xml' ) )/*/i">
				<xsl:message>Попытка найти имя в потру текущего автора</xsl:message>
				<xsl:apply-templates select="document ( concat( '/m8/', $prefix, '/', name(), '/', $currentAuthorName, '/', $avatar, '/', $currentQuestName, '/port.xml' ) )/*/i/*" mode="titleWord"/>
				<!--	<xsl:variable name="nameValueFromPort" select="name( document ( concat( '/m8/', @type, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' ) )/*/name/* )"/>
				<xsl:choose>
					<xsl:when test="starts-with( $nameValueFromPort, 'l' )"><xsl:value-of select="document ( concat( '/m8/d/', $nameValueFromPort, '/value.xml' ) )/*"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$nameValueFromPort"/></xsl:otherwise>
				</xsl:choose>-->
			</xsl:when>
			<xsl:when test="document ( concat( '/m8/', $prefix, '/', name(), '/', $author, '/', $avatar, '/', $quest, '/port.xml' ) )/*/i">
				<xsl:message>Попытка найти имя в потру текущего автора</xsl:message>
				<xsl:apply-templates select="document ( concat( '/m8/', $prefix, '/', name(), '/', $author, '/', $avatar, '/', $quest, '/port.xml' ) )/*/i/*" mode="titleWord"/>
				<!--	<xsl:variable name="nameValueFromPort" select="name( document ( concat( '/m8/', @type, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' ) )/*/name/* )"/>
				<xsl:choose>
					<xsl:when test="starts-with( $nameValueFromPort, 'l' )"><xsl:value-of select="document ( concat( '/m8/d/', $nameValueFromPort, '/value.xml' ) )/*"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$nameValueFromPort"/></xsl:otherwise>
				</xsl:choose>-->
			</xsl:when>
			<xsl:when test="document ( concat( '/m8/', $prefix, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' ) )/*/i">
				<xsl:message>Попытка найти имя в потру аватар-автора</xsl:message>
				<xsl:apply-templates select="document ( concat( '/m8/', $prefix, '/', name(), '/', $author, '/', $avatar, '/', name(), '/port.xml' ) )/*/i/*" mode="titleWord"/>
			</xsl:when>
			<xsl:when test="document ( concat( '/m8/', $prefix, '/', name(), '/', $avatar, '/', $avatar, '/', name(), '/port.xml' ) )/*/i">
				<xsl:message>Попытка найти имя в потру аватар-автора</xsl:message>
				<xsl:apply-templates select="document ( concat( '/m8/', $prefix, '/', name(), '/', $avatar, '/', $avatar, '/', name(), '/port.xml' ) )/*/i/*" mode="titleWord"/>
			</xsl:when>
			<xsl:when test="document ( concat( '/m8/', substring(name(),1,1), '/', name(), '/subject_r.xml' ) )/*/*/*/*">
				<xsl:if test="not($currentQuestName)">
					<xsl:variable name="parentFact" select="document( concat( '/m8/', substring(name(),1,1), '/', name(), '/subject_r.xml' ) )/*/*/*/*[1]"/>
					<xsl:variable name="parentFactName" select="name($parentFact)"/>
					<xsl:apply-templates select="document ( concat( '/m8/', $prefix, '/', name(), '/', $avatar, '/', $avatar, '/', $parentFactName, '/port.xml' ) )/*/r/*" mode="titleWord"/>
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
		<xsl:value-of select="translate( substring( name( . ), 2 ), '_', '.' )"/>
	</xsl:template>
	<xsl:template match="@*" mode="number">
		<xsl:value-of select="translate( substring-after( ., 'r' ), '_', '.' )"/>
	</xsl:template>
	<!--

	-->
	<xsl:template name="editParamOfPort">
		<xsl:param name="action"/>
		<xsl:param name="hidden"/>
		<xsl:param name="inputType"/>
		<xsl:param name="subjectName"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedValue"/>
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="titleSelect"/>
		<form id="editParamOfPort">
			<xsl:attribute name="action"><xsl:choose><xsl:when test="$action"><xsl:value-of select="$action"/></xsl:when><xsl:otherwise><xsl:value-of select="$startID"/></xsl:otherwise></xsl:choose>/</xsl:attribute>
			<xsl:if test="$predicateName = 'n' ">
				<xsl:attribute name="enctype"><xsl:text>multipart/form-data</xsl:text></xsl:attribute>
				<xsl:attribute name="method"><xsl:text>post</xsl:text></xsl:attribute>
			</xsl:if>
			<xsl:if test="$hidden">
				<xsl:for-each select="exsl:node-set($hidden)/*">
					<input type="hidden" name="a0">
						<xsl:attribute name="name"><xsl:value-of select="name()"/></xsl:attribute>
						<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
					</input>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="$predicateName != 'n' ">
				<xsl:if test="$subjectName">
					<input type="hidden" name="a1" value="{$subjectName}"/>
				</xsl:if>
				<input type="hidden" name="a2" value="{$predicateName}"/>
				<xsl:if test="$selectedValue">
					<input type="hidden" name="a0">
						<xsl:attribute name="value"><xsl:choose><xsl:when test="$selectedValue/@triple"><xsl:value-of select="$selectedValue/@triple"/></xsl:when><xsl:otherwise><xsl:value-of select="name($selectedValue/*)"/></xsl:otherwise></xsl:choose></xsl:attribute>
					</input>
				</xsl:if>
			</xsl:if>
			<xsl:call-template name="inputParamOfPortPre">
				<xsl:with-param name="inputType" select="$inputType"/>
				<xsl:with-param name="subjectName" select="$subjectName"/>
				<xsl:with-param name="predicateName" select="$predicateName"/>
				<xsl:with-param name="selectedValue" select="$selectedValue"/>
				<xsl:with-param name="sourceValue" select="$sourceValue"/>
				<xsl:with-param name="sortSelect" select="$sortSelect"/>
				<xsl:with-param name="titleSelect" select="$titleSelect"/>
			</xsl:call-template>
		</form>
	</xsl:template>
	<!--

	-->
	<xsl:template name="inputParamOfPortPre">
		<xsl:param name="inputType"/>
		<xsl:param name="subjectName"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedValue"/>
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="titleSelect"/>
		<!--<xsl:variable name="predicateName" select="name()"/> style="padding: .8em"-->
		<xsl:choose>
			<xsl:when test="$sourceValue">
				<!--<xsl:for-each select="exsl:node-set($sourceValue)/*"><div>[<xsl:value-of select="."/>]</div></xsl:for-each>-->
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="subjectName" select="$subjectName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="$sourceValue"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="document( concat( '/m8/', substring($predicateName,1,1), '/', $predicateName, '/', $avatar, '/', $avatar, '/', $predicateName, '/port.xml' ) )/*/n">
				<xsl:variable name="currentListName" select="name(document( concat( '/m8/', substring($predicateName,1,1), '/', $predicateName, '/', $avatar, '/', $avatar, '/', $predicateName, '/port.xml' ) )/*/n/*)"/>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="subjectName" select="$subjectName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="document( concat( '/m8/', substring($currentListName,1,1), '/', $currentListName, '/value.xml'  ) ) /*"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="document( '/m8/r/r/index.xml' )/*/predicate/*[name()=$predicateName]">
				<!--<xsl:value-of select="$predicateName"/>-->
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="subjectName" select="$subjectName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="document( concat( '/m8/r/r/predicate_', $predicateName, '.xml' ) )/*/*/*"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="subjectName" select="$subjectName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template name="inputParamOfPort">
		<xsl:param name="inputType"/>
		<xsl:param name="subjectName"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedValue"/>
		<!-- здесь должна прийти сама нода для обращения к ней без /*, но внутри должна быть нода активирующего трипла для удления -->
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="codeSelect"/>
		<xsl:param name="titleSelect"/>
		<!--<xsl:variable name="predicateValues" select="//*[name()=$predicateName]/*"/>
		Здесь можно былоо бы указать /*/*[name()=$predicateName] для порта, эти шаблон можно попытаться применить и для других случаев  class="input_x" class="input_x" -->
		<xsl:message>позже имеющиеся значения нужно привести сюда из источника, т.к. сейчас шаблон смотрит на порт взятый с потолка</xsl:message>
		<xsl:variable name="params_of_quest" select="document( concat( '/m8/', substring($fact,1,1), '/', $fact, '/', $author, '/', $avatar, '/', $quest, '/port.xml' ) )/*/*"/>
		<!--<xsl:value-of select="name(exsl:node-set($sourceValue)/*)"/>-->
		<xsl:choose>
			<xsl:when test="$predicateName = 'n'">
				<input type="file" name="file" onchange="this.form.submit()"/>
				<xsl:if test="name($selectedValue) != 'r'">
					<a href="/base/{name($selectedValue)}/value.tsv">text</a>|<a href="/m8/{substring(name($selectedValue),1,1)}/{name($selectedValue)}/value.xml">xml</a>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$predicateName = 'd' ">
				<xsl:variable name="name">
					<xsl:apply-templates select="$selectedValue" mode="titleWord"/>
				</xsl:variable>
				<textarea name="a3" placeholder="описание объекта" onchange="this.form.submit()" cols="32" rows="3">
					<xsl:if test="$name=''">
						<xsl:attribute name="onfocus"><xsl:text>$(this).val('')</xsl:text></xsl:attribute>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="$name"/>
				</textarea>
				<!--<input name="a3" type="file">dd</input>
				normalize-space( <xsl:value-of select="name($selectedValue)"/>!<textarea rows="10" cols="45" name="a3"><xsl:apply-templates select="$selectedValue" mode="titleWord"/></textarea> <xsl:apply-templates select="$selectedValue" mode="titleWord"/>sortSelect -->
			</xsl:when>
			<xsl:when test="exsl:node-set($sourceValue)/div">
				<xsl:message>Для вывода списков из tsv</xsl:message>
				<xsl:variable name="objectTitle">
					<xsl:apply-templates select="$selectedValue" mode="titleWord"/>
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
					<xsl:when test="$inputType">
						<xsl:for-each select="exsl:node-set($sourceValue)/*">
							<xsl:sort select="span[$sortSelect]"/>
							<li class="list-group-item">
								<label><input type="{$inputType}" name="a3" onchange="this.form.submit()" value="{span[1]}">
									<xsl:if test="span[1] = $objectTitle">
										<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
									</xsl:if>
								</input>
								<!--<xsl:value-of select="span[position()=$titleSpan]"/>-->
								<xsl:value-of select="span[number($titleSpan)]"/></label>
							</li>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:variable name="valueNames">
								<xsl:for-each select="$params_of_quest[name()=$predicateName]/*">
									<xsl:element name="{name()}"><xsl:apply-templates select="." mode="titleWord"/></xsl:element>
								</xsl:for-each>
							</xsl:variable>
						<!--	[<code><xsl:copy-of select="exsl:node-set($valueNames)"/></code>]-->
						<select name="a3" onchange="this.form.submit()">
							<option/>		
							
							<xsl:for-each select="exsl:node-set($sourceValue)/*">
								<xsl:sort select="span[$sortSelect]"/>
								<xsl:variable name="currentVal" select="span[1]"/>
								<xsl:if test="not(exsl:node-set($valueNames)/*[.=$currentVal]) or $currentVal=$objectTitle">
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
			<xsl:when test="exsl:node-set($sourceValue)/*">
				<!--[2] выводить селект нужно вероятно всегда когда есть список-->
				<xsl:choose>
					<xsl:when test="$inputType">
						<xsl:for-each select="exsl:node-set($sourceValue)/*">
							<!--<xsl:value-of select="name($selectedValue)"/> = <xsl:value-of select="name()"/>-->
							<input type="{$inputType}" name="a3" value="{name()}" onchange="this.form.submit()">
								<xsl:if test="$inputType='radio' and $selectedValue and name()=name($selectedValue)">
									<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
								</xsl:if>
							</input>
							<xsl:apply-templates select="." mode="titleWord"/>
							<!-- //-->
							<br/>
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="count(exsl:node-set($sourceValue)/*) = 1 and name(exsl:node-set($sourceValue)/*)=$da">
						<input type="checkbox" name="a3" onchange="this.form.submit()" value="{$da}">
							<xsl:if test="name($selectedValue)=$da">
								<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
							</xsl:if>
						</input>
					</xsl:when>
					<xsl:otherwise>
						<select name="a3" onchange="this.form.submit()">
							<!--onchange="this.form.submit()"  -->
							<option/>
							<!--<xsl:if test="not(exsl:node-set($sourceValue)/r)"></xsl:if>-->
							<xsl:for-each select="exsl:node-set($sourceValue)/*">
								<!--<xsl:sort select="name()"/>-->
								<xsl:variable name="valueName" select="name()"/>
								<xsl:if test="not($params_of_quest[name()=$predicateName]/*[name()=$valueName]) or name()=name($selectedValue)">
									<option value="{$valueName}">
										<xsl:if test="$valueName=name($selectedValue)">
											<xsl:attribute name="selected"><xsl:value-of select="'selected'"/></xsl:attribute>
										</xsl:if>
										<xsl:variable name="material" select="name( document( '/m8/i/i5539574630680978038/role3.xml' )/*/teplotn/teplotn/* )"/>
										<xsl:variable name="title">
											<!-- <xsl:if test="0 or 20 > position()">
												
												</xsl:if>-->
											<xsl:choose>
												<xsl:when test="$predicateName=$material">
													<xsl:value-of select="$valueName"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:apply-templates select="." mode="titleWord"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<!--<xsl:variable name="material" select="name( document( '/m8/i/i5539574630680978038/role3.xml' )/*/teplotn/teplotn/* )"/>
											<xsl:message>почему-то вывод имен материалов через полный titleWord виснет примерно на 43 позиции (без разницы какой)</xsl:message>
											<xsl:choose>
												<xsl:when test="$predicateName=$material">
										
													<xsl:variable name="materiall" select="document ( concat( '/m8/n/', $valueName, '/', $avatar, '/', $avatar, '/', $valueName, '/port.xml' ) )/*/i/*"/>
													<xsl:if test="0 and 4 > position()">
													<xsl:value-of select="$valueName"/>
													</xsl:if>
												</xsl:when>
												<xsl:otherwise>
													<xsl:variable name="title">
														<xsl:apply-templates select="." mode="titleWord"/>
													</xsl:variable>
													<xsl:value-of select="substring($title, 1, 37)"/>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:apply-templates select="." mode="titleWord"/>
											<xsl:value-of select="$title"/>-->
										<xsl:value-of select="substring($title, 1, 37)"/>
									</option>
								</xsl:if>
							</xsl:for-each>
						</select>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!--<xsl:value-of select="$predicateValues[1]"/>-->
				<xsl:variable name="title">
					<xsl:apply-templates select="$selectedValue" mode="titleWord"/>
				</xsl:variable>
				<input type="text" name="a3" onchange="this.form.submit()">
					<!--onmouseout	onchange="this.form.submit()" -->
					<!-- class="input_x"  -->
					<xsl:attribute name="value"><xsl:value-of select="$title"/></xsl:attribute>
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
</xsl:stylesheet>
