<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" extension-element-prefixes="func" xmlns:m8="http://m8data.com">
	<xsl:include href="get_name.xsl"/>
	<!--
-->
<!--	<func:function name="m8:path">
		<xsl:param name="level1"/>
		<xsl:param name="level2"/>
		<xsl:param name="level3"/>
		<xsl:param name="level4"/>
		<xsl:choose>
			<xsl:when test="$level4"><func:result select="concat( $start/@DOCUMENT_ROOT, 'm8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '/', $level3, '/', $level4, '.xml' )"/></xsl:when>
			<xsl:when test="$level3"><func:result select="concat( $start/@DOCUMENT_ROOT, 'm8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '/', $level1, '/', $level3, '.xml' )"/></xsl:when>
			<xsl:when test="$level2"><func:result select="concat( $start/@DOCUMENT_ROOT, 'm8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '.xml' )"/></xsl:when>
			<xsl:when test="$level1"><func:result select="concat( $start/@DOCUMENT_ROOT, 'm8/user/', $level1, '/type.xml' )"/></xsl:when>
			<xsl:otherwise>ERROR</xsl:otherwise>
		</xsl:choose>
	</func:function>-->
	<func:function name="m8:path">
		<xsl:param name="level1"/>
		<xsl:param name="level2"/>
		<xsl:param name="level3"/>
		<xsl:param name="level4"/>
		<xsl:choose>
			<xsl:when test="$level4"><func:result select="document( concat( $start/@DOCUMENT_ROOT, '/m8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '/', $level3, '/', $level4, '.xml' ) )/*"/></xsl:when>
			<xsl:when test="$level3"><func:result select="document( concat( $start/@DOCUMENT_ROOT, '/m8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '/', $level1, '/', $level3, '.xml' ) )/*"/></xsl:when>
			<!--<xsl:when test="$level2 and $level1='i3627106994546558181'"><func:result select="document (concat( $start/@DOCUMENT_ROOT, 'm8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '.xml' ) )/*"/></xsl:when>-->
			<xsl:when test="$level2"><func:result select="document( concat( $start/@DOCUMENT_ROOT, '/m8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '.xml' ) )/*"/></xsl:when>
			<xsl:when test="$level1"><func:result select="document( concat( $start/@DOCUMENT_ROOT, '/m8/user/', $level1, '/type.xml' ) )/*"/></xsl:when>
			<xsl:otherwise><func:result select="document( concat( $start/@DOCUMENT_ROOT, '/m8/n/n/', $author, '/n/port.xml' ) )/*"/></xsl:otherwise>
		</xsl:choose>
	</func:function>	
	<func:function name="m8:dir">
		<xsl:param name="level1"/>
		<xsl:param name="level2"/>
		<xsl:param name="level3"/>
		<xsl:choose>
			<xsl:when test="$level3"><func:result select="concat( '/m8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '/', $level3 )"/></xsl:when>
			<xsl:when test="$level2"><func:result select="concat( '/m8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '/', $level1 )"/></xsl:when>
			<xsl:when test="$level1"><func:result select="concat( '/m8/', substring( $level1, 1, 1 ), '/', $level1 )"/></xsl:when>
			<xsl:otherwise><func:result select="'/m8'"/></xsl:otherwise>
		</xsl:choose>
	</func:function>
	<!--<func:function name="m8:dir2">
		<xsl:param name="level1"/>
		<xsl:param name="level2"/>
		<xsl:param name="level3"/>
		<xsl:choose>
			<xsl:when test="$level3"><func:result select="concat( '/m8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2, '/', $level3 )"/></xsl:when>
			<xsl:when test="$level2"><func:result select="concat( '/m8/', substring( $level1, 1, 1 ), '/', $level1, '/', $level2 )"/></xsl:when>
			<xsl:when test="$level1"><func:result select="concat( '/m8/', substring( $level1, 1, 1 ), '/', $level1 )"/></xsl:when>
			<xsl:otherwise>ERROR</xsl:otherwise>
		</xsl:choose>
	</func:function>	-->	
	<!--

//-->
	<!--<xsl:variable name="da" select="ss"/>-->
	<!--
	информация по стартовому xml (здесь излишне читать порт, т.к. иногда он нужен)-->
	<xsl:variable name="start" select="/*"/>
	<xsl:variable name="m8root" select="$start/@DOCUMENT_ROOT"/>
	<xsl:variable name="ctrl" select="$start/@ctrl"/>
	<xsl:variable name="fact" select="$start/@fact"/>
	<xsl:variable name="author" select="$start/@author"/>
	<xsl:variable name="avatar" select="$start/@avatar"/>
	<xsl:variable name="quest" select="$start/@quest"/>
	<xsl:variable name="xsStartID" select="m8:dir( $fact )"/>
	<xsl:variable name="sStartID" select="m8:dir( $fact, $author, $quest )"/>
	<xsl:variable name="startID" select="concat( '/', $ctrl, $sStartID )"/>
	<xsl:variable name="startGroup" select="$start/@group"/>
	<xsl:variable name="user" select="$start/@user"/>
	<xsl:variable name="time" select="$start/@time"/>
	<!--<xsl:variable name="adminMode"/>-->
	<xsl:variable name="adminMode" select="$start/@adminMode"/>
	<!-- //-->
	<xsl:variable name="localtime" select="$start/@localtime"/>
	<!--


//-->
	<!--


	-->
	<xsl:template name="editParamOfPort">
		<xsl:param name="action"/>
		<xsl:param name="currentStep"/>
		<xsl:param name="size"/>
		<xsl:param name="hidden"/>
		<xsl:param name="message"/>
		<xsl:param name="inputType"/>
		<xsl:param name="questName"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedValue"/>
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="titleSelect"/>
		<xsl:param name="ajaxMethod"/>
		<xsl:if test="not($sourceValue)" xml:space="только для текстовых инпутов для корректного отображения всплывающих сообщений">
			<xsl:attribute name="title">
				<xsl:choose xml:space="2016-06-10: вносится наверх, а не в инпут т.к. при стилизации select2 сообщение нужно показывать не с инпута">
					<xsl:when test="$message"><xsl:value-of select="$message"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="$selectedValue/@message"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>		
		</xsl:if>
		<!--<span style="font-size: .8em"></span>-->
		<form id="editParamOfPort" selectedValue="{name($selectedValue)}">
			<xsl:attribute name="action"><xsl:choose><xsl:when test="$action"><xsl:value-of select="$action"/></xsl:when><xsl:otherwise><xsl:value-of select="$startID"/></xsl:otherwise></xsl:choose>/</xsl:attribute>
			<xsl:if test="$predicateName = 'n' ">
				<xsl:attribute name="ENCTYPE">multipart/form-data</xsl:attribute>
				<xsl:attribute name="method">POST</xsl:attribute>
			</xsl:if>
			<xsl:if test="$ajaxMethod='load'">
				<input type="hidden" id="refreshYes"/>
			</xsl:if>
			<xsl:if test="$message or $selectedValue/@message">
				<!--<input type="hidden" name="{$shag}" value="{$currentStep}"/>-->
				<input type="hidden" name="b1" value="{$calcName}"/>
				<input type="hidden" name="b2" value="{$shag}"/>
				<input type="hidden" name="b3" value="{$currentStep}"/>
				<input type="hidden" name="b5" value="{$calcName}"/>
			</xsl:if>
			<xsl:if test="$hidden">
				<xsl:for-each select="exsl:node-set($hidden)/*">
					<input type="hidden">
						<xsl:attribute name="name"><xsl:value-of select="name()"/></xsl:attribute>
						<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
					</input>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="$predicateName != 'n' ">
				<xsl:if test="$questName">
					<input type="hidden" name="quest" value="{$questName}"/>
				</xsl:if>
			</xsl:if>
			<!--<xsl:if test="$predicateName != 'n' ">
				<xsl:if test="$subjectName">
					<input type="hidden" name="a1" value="{$subjectName}"/>
				</xsl:if>
				<input type="hidden" name="a2" value="{$predicateName}"/>
				<xsl:if test="$selectedValue">
					<input type="hidden" name="a0">
						<xsl:attribute name="value"><xsl:choose><xsl:when test="$selectedValue/@triple"><xsl:value-of select="$selectedValue/@triple"/></xsl:when><xsl:otherwise><xsl:value-of select="name($selectedValue/*)"/></xsl:otherwise></xsl:choose></xsl:attribute>
					</input>
				</xsl:if>
			</xsl:if>-->
			<xsl:call-template name="inputParamOfPortPre">
				<xsl:with-param name="inputType" select="$inputType"/>
				<xsl:with-param name="size" select="$size"/>
				<xsl:with-param name="questName" select="$questName"/>
				<xsl:with-param name="predicateName" select="$predicateName"/>
				<xsl:with-param name="selectedValue" select="$selectedValue"/>
				<xsl:with-param name="sourceValue" select="$sourceValue"/>
				<xsl:with-param name="sortSelect" select="$sortSelect"/>
				<xsl:with-param name="titleSelect" select="$titleSelect"/>
				<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
			</xsl:call-template>
		</form>
	</xsl:template>
	<!--

	-->
	<xsl:template name="inputParamOfPortPre">
		<xsl:param name="inputType"/>
		<xsl:param name="size"/>
		<xsl:param name="questName"/>
		<xsl:param name="predicateName"/>
		<xsl:param name="selectedValue"/>
		<xsl:param name="sourceValue"/>
		<xsl:param name="sortSelect"/>
		<xsl:param name="titleSelect"/>
		<xsl:param name="option"/>
		<xsl:param name="ajaxMethod"/>
		<!--<xsl:variable name="predicateName" select="name()"/> style="padding: .8em"-->
		<xsl:variable name="parentPredicateName" select="name( m8:path( $predicateName, 'subject_r' )/*/*[1] )"/>
		<xsl:choose>
			<xsl:when test="$sourceValue">
				<!--<xsl:for-each select="exsl:node-set($sourceValue)/*"><div>[<xsl:value-of select="."/>]</div></xsl:for-each>-->
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="$sourceValue"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="m8:path( $predicateName, $avatar, $parentPredicateName, 'port' )/n" xml:space="вывод списка из tsv-файла">
				<xsl:variable name="currentListName" select="name( m8:path( $predicateName, $avatar, $parentPredicateName, 'port' )/n/*)"/>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="m8:path( $currentListName, 'value' )"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
					<xsl:with-param name="option" select="$option"/>
					<!--<xsl:element name="option"/>
					</xsl:with-param>-->
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="m8:path( 'r', 'index' )/predicate/*[name()=$predicateName]" xml:space="вывод экземпляров типа">
				<!--<xsl:value-of select="$predicateName"/>-->
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sourceValue" select="m8:path( 'r', concat( 'predicate_', $predicateName ) )/*"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
					<xsl:with-param name="option">
						<xsl:element name="option"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="inputParamOfPort">
					<xsl:with-param name="inputType" select="$inputType"/>
					<xsl:with-param name="size" select="$size"/>
					<xsl:with-param name="questName" select="$questName"/>
					<xsl:with-param name="predicateName" select="$predicateName"/>
					<xsl:with-param name="selectedValue" select="$selectedValue"/>
					<xsl:with-param name="sortSelect" select="$sortSelect"/>
					<xsl:with-param name="titleSelect" select="$titleSelect"/>
					<xsl:with-param name="ajaxMethod" select="$ajaxMethod"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--

	-->
	<xsl:template name="inputParamOfPort">
		<xsl:param name="inputType"/>
		<xsl:param name="size"/>
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
		<!--<xsl:variable name="predicateValues" select="//*[name()=$predicateName]/*"/>
		Здесь можно былоо бы указать /*/*[name()=$predicateName] для порта, эти шаблон можно попытаться применить и для других случаев  class="input_x" class="input_x" -->
		<xsl:message>позже имеющиеся значения нужно привести сюда из источника, т.к. сейчас шаблон смотрит на порт взятый с потолка</xsl:message>
		<xsl:variable name="params_of_quest" select="m8:path( $fact, $author, $quest, 'port' )/*"/>
		<!--<xsl:value-of select="name(exsl:node-set($sourceValue)/*)"/>-->
		<!--<xsl:copy-of select="$sourceValue"/>-->
		<xsl:choose>
			<!--
							ВЫВОД ЗАПРОСА ФАЙЛА
-->
			<xsl:when test="$predicateName = 'n'">
				<input type="file" name="file">
					<xsl:if test="not($ajaxMethod)">
						<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
					</xsl:if>
				</input>
				<xsl:if test="name($selectedValue) != 'r'">
					<a href="/base/{name($selectedValue)}/value.tsv">text</a>|<a href="/m8/{substring(name($selectedValue),1,1)}/{name($selectedValue)}/value.xml">xml</a>
				</xsl:if>
			</xsl:when>
			<!--
							ВЫВОД TEXTAREA
-->
			<xsl:when test="$predicateName = 'd' ">
				<xsl:variable name="name">
					<xsl:apply-templates select="$selectedValue" mode="titleWord"/>
				</xsl:variable>
				<textarea name="{$predicateName}" placeholder="описание объекта" cols="32" rows="3">
					<xsl:if test="not($ajaxMethod)">
						<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
					</xsl:if>
					<xsl:if test="$name=''">
						<xsl:attribute name="onfocus"><xsl:text>$(this).val('')</xsl:text></xsl:attribute>
						<xsl:text> </xsl:text>
					</xsl:if>
					<xsl:value-of select="$name"/>
				</textarea>
				<!--<input name="{$predicateName}" type="file">dd</input>
				normalize-space( <xsl:value-of select="name($selectedValue)"/>!<textarea rows="10" cols="45" name="{$predicateName}"><xsl:apply-templates select="$selectedValue" mode="titleWord"/></textarea> <xsl:apply-templates select="$selectedValue" mode="titleWord"/>sortSelect -->
			</xsl:when>
			<!--
							ВЫВОД ИЗ СПИСКА DIV-ов
-->
			<xsl:when test="exsl:node-set($sourceValue)/div">
				<xsl:message>Для вывода списков из tsv</xsl:message>
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
							<!-- <li class="list-group-item"> -->
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
							<!--<xsl:value-of select="span[position()=$titleSpan]"/>-->
							<label class="list-group-item" for="{span[1]}">
								<xsl:value-of select="span[number($titleSpan)]"/>
							</label>
							<!-- </li> -->
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
						<!--	[<code><xsl:copy-of select="exsl:node-set($valueNames)"/></code>] clas="custom-select"
						<xsl:apply-templates select="$sourceValue/*" mode="serialize"/>
						<xsl:copy-of select="$sourceValue"/> class="custom-select" -->
						<select name="{$predicateName}" size="{$size}" objectTitle="{$objectTitle}">
							<!-- -->
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="exsl:node-set($sourceValue)/*[20]" xml:space="для городов в калькуляторе TN например">custom-<xsl:value-of select="$ajaxMethod"/>-select</xsl:when>
									<xsl:otherwise>simple-<xsl:value-of select="$ajaxMethod"/>-select</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
							<!--	<xsl:attribute name="id">
									<xsl:choose>
										<xsl:when test="exsl:node-set($sourceValue)/*[20]">searchSelect</xsl:when>
										<xsl:otherwise>simpleSelect</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>-->

							<xsl:if test="not($ajaxMethod)">
								<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
							</xsl:if>
							<xsl:copy-of select="$option"/>
							<xsl:for-each select="exsl:node-set($sourceValue)/*">
								<xsl:sort select="span[$sortSelect]"/>
								<xsl:variable name="currentVal" select="span[1]"/>
								<xsl:if test="1 or not(exsl:node-set($valueNames)/*[.=$currentVal]) or $currentVal=$objectTitle">
									<!-- xml:space="зачем нужна эта проверка не понятно, поэтому 1"-->
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
				<xsl:choose>
					<xsl:when test="$inputType">
						<xsl:for-each select="exsl:node-set($sourceValue)/*">
							<xsl:sort select="@sort"/>
							<!--<xsl:value-of select="name($selectedValue)"/> = <xsl:value-of select="name()"/>-->
							<input class="input-radio" type="{$inputType}" name="{$predicateName}" value="{name()}" id="{name()}">
								<xsl:if test="not($ajaxMethod)">
									<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
								</xsl:if>
								<xsl:if test="@description">
									<xsl:attribute name="description"><xsl:value-of select="@description"/></xsl:attribute>
								</xsl:if>
								<!--<xsl:if test="$inputType='radio' and $selectedValue and name()=name($selectedValue)">
									<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
								</xsl:if>-->
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
									<!--<xsl:value-of select="substring-after(@title, ' ')"/>-->
									<!--<xsl:apply-templates select="." mode="titleWord"/>-->
								</p>
							</label>
							<!-- <img src="{}" alt=""/>
							//-->
						</xsl:for-each>
					</xsl:when>
					<xsl:when test="count(exsl:node-set($sourceValue)/*) = 1 and name(exsl:node-set($sourceValue)/*)=$da">
						<input type="checkbox" name="{$predicateName}" value="{$da}">
							<xsl:if test="not($ajaxMethod)">
								<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
							</xsl:if>
							<xsl:if test="name($selectedValue)=$da">
								<xsl:attribute name="checked"><xsl:value-of select="'checked'"/></xsl:attribute>
							</xsl:if>
						</input>
					</xsl:when>
					<xsl:otherwise>
						<select name="{$predicateName}">
							<!--simple-select class="simple-{$ajaxMethod}-select"-->
							<xsl:if test="not($ajaxMethod)">
								<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
							</xsl:if>
							<xsl:attribute name="class">
								<xsl:choose>
									<xsl:when test="exsl:node-set($sourceValue)/*[20]" xml:space="для городов в калькуляторе TN например">custom-</xsl:when>
									<xsl:otherwise>simple-</xsl:otherwise>
								</xsl:choose>
								<xsl:value-of select="$ajaxMethod"/>
								<xsl:text>-select</xsl:text>
							</xsl:attribute>
							<!--onchange="this.form.submit()"  -->
							<xsl:copy-of select="$option"/>
							<!--   -->
							<!--<xsl:if test="not(exsl:node-set($sourceValue)/r)"></xsl:if>-->
							<xsl:for-each select="exsl:node-set($sourceValue)/*">
								<xsl:sort select="@sort"/>
								<!--//-->
								<xsl:variable name="valueName" select="name()"/>
								<xsl:if test="not($params_of_quest[name()=$predicateName]/*[name()=$valueName]) or name()=name($selectedValue)">
									<option value="{$valueName}">
										<xsl:if test="$valueName=name($selectedValue)">
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
												<xsl:otherwise>
													<xsl:apply-templates select="." mode="titleWord"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:variable>
										<!--<xsl:variable name="material" select="name( document( '/m8/i/i5539574630680978038/role3.xml' )/teplotn/teplotn/* )"/>
											<xsl:message>почему-то вывод имен материалов через полный titleWord виснет примерно на 43 позиции (без разницы какой)</xsl:message>
											<xsl:choose>
												<xsl:when test="$predicateName=$material">
										
													<xsl:variable name="materiall" select="document ( m8:path( '/m8/n/', $valueName, '/', $avatar, '/', $avatar, '/', $valueName, '/port.xml' /*/i/*"/>
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
										<xsl:value-of select="$title"/>
										<!--substring($title, 1, 50)-->
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
				<!--<xsl:value-of select="$predicateValues[1]"/> size="{$size}"-->
				<xsl:variable name="title">
					<xsl:apply-templates select="$selectedValue" mode="titleWord"/>
				</xsl:variable>
				<input type="text" name="{$predicateName}" size="{$size}">
					<xsl:if test="not($ajaxMethod)">
						<xsl:attribute name="onchange">this.form.submit()</xsl:attribute>
					</xsl:if>
					<xsl:if test="$selectedValue/@invalid or $selectedValue/../../@invalid">
						<xsl:attribute name="invalid">invalid</xsl:attribute>
						<!--<xsl:copy-of select="$selectedValue/@invalid"/>-->
						<!--<xsl:copy-of select="$selectedValue/@title"/>-->
					</xsl:if>
					<!--<xsl:if test="$selectedValue/@message">
							<xsl:copy-of select="$selectedValue/@message"/>
						</xsl:if>									
					onmouseout	onchange="this.form.submit()" -->
					<!-- class="input_x"  -->
					<xsl:attribute name="value"><xsl:choose><xsl:when test="starts-with( name($selectedValue), 'r' )"><xsl:value-of select="translate( $title, '.', ',' )"/></xsl:when><xsl:otherwise><xsl:value-of select="$title"/></xsl:otherwise></xsl:choose></xsl:attribute>
				</input>
				<xsl:if test="starts-with( $title, 'http' )">
					<xsl:text> </xsl:text>
					<a href="{$title}">link</a>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

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
</xsl:stylesheet>
