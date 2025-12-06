## T001 – Company Codes

The `T001` table defines the top-level organizational entities within the nano-mm model. A company code represents a 
legally independent accounting unit that serves as the foundation for all financial posting, valuation logic, and 
cross-module integration. In SAP’s architecture, many procurement activities ultimately reconcile back to the financial 
layer, making the company code a central anchor for consistent reporting and data alignment. Within this project, `T001` 
provides the structural separation needed to simulate multi-entity procurement environments, where each company may 
operate under different currencies, regulatory contexts, and country-specific rules. This separation also enables 
realistic downstream analytics, such as spend segmentation by entity or intercompany purchase patterns. Architecturally, 
the table mirrors SAP’s standard customizing table T001, reinforcing the distinction between organizational 
configuration and transactional procurement data. The company code is therefore not merely a label but a key modeling 
artifact that governs how procurement processes interact with finance and compliance in an enterprise system.

### Cryptic Name: Why “T001”?
In SAP naming conventions, tables beginning with **T** typically denote *customizing* or configuration objects rather 
than transactional data. The number **001** reflects its role as one of the earliest and most fundamental organizational 
configuration tables in the Financial Accounting (FI) module. Although used throughout Materials Management, the name 
originates from FI’s need to define company codes as core accounting entities.

### Field Explanations

### Field Explanations

- **BUKRS** (***B**uchungskreis → Company Code*)  
  A four-character identifier representing a legally independent accounting entity. It is the primary key of the table 
and the foundational reference used throughout procurement and financial integration.

- **BUTXT** (***B**uchungskreis **T**e**xt** → Company Code Name*)  
  Descriptive name of the company code. Its purpose is semantic, providing a readable organizational label for reporting 
and user interfaces.

- **LAND1** (***L**and → Country*)  
  Indicates the country in which the company code is legally registered. This parameter influences tax rules, 
localization, and compliance settings across processes.

- **WAERS** (***W**ä**h**rung → Currency*)  
  Defines the default operational currency of the company code. It plays a central role in valuation, invoice 
processing, and all monetary reporting.

## T001W – Plants

The `T001W` table represents the plant, one of the core organizational units in the nano-mm model. A plant can 
correspond to a physical warehouse, a distribution center, a production facility, or even a logical location depending 
on the business scenario. Plants serve as the primary nodes where procurement activities materialize: materials are 
received, stored, consumed, and valuated at the plant level. This table provides the structural bridge between 
organizational configuration and operational procurement processes. It underpins inventory management, goods movements, 
purchasing analytics, and cross-plant supply flows. Within this project’s simulation, `T001W` enables multi-plant 
procurement scenarios, regionalized supply chains, and realistic stock distribution patterns. As with its SAP 
counterpart, the table plays a central role in determining where materials reside and how they are accounted for, 
forming an essential foundation for downstream tables such as MARD (storage-location-level stock) and MBEW (valuation). 
Without plant-level structure, no meaningful logistics or procurement modeling can occur.

### Cryptic Name: Why “T001W”?
The prefix **T** indicates a customizing or configuration table. Just like T001 stores company code configuration, 
**T001W** extends the organizational definition by assigning plant-level entities. The suffix **W** originates from the 
German word *Werk* (plant or factory), which SAP traditionally abbreviates with the letter **W** when naming structures 
related to plant definitions.

- **WERKS** (***W**erk → Plant*)  
  The plant identifier. A four-character key representing a physical or logical location where procurement, inventory, 
or production processes occur. It is the primary key of this table and one of the most frequently referenced 
organizational fields in SAP MM.

- **NAME1** (***Name →*** Plant Name)  
  Descriptive name of the plant. Used across UIs, reports, and analytics to provide a readable label for operational 
users. It plays no functional role beyond identification and clarity.

- **LAND1** (***L**and → Country*)  
  Indicates the country in which the plant is located. This value influences taxation rules, international goods 
movement processes, and logistical constraints across procurement and inventory operations.

## MARA – General Material Master Data

The `MARA` table forms the central definition of a material within the nano-mm model. It stores attributes that are 
valid across all plants and organizational units, making it the foundational layer on which all other material-dependent 
views are built. In SAP’s architecture, MARA is the core of the Material Master: it provides the universal identifiers 
and high-level classifications that purchasing, inventory management, valuation, and sales processes rely on. Without 
MARA, no material could exist in any downstream table such as MARD (plant and storage-level stock), EKPO (purchase order 
items), or MBEW (valuation). The table’s role in this project is to anchor synthetic material behavior, allowing the 
simulation of product hierarchies, material types, and base units of measure across the entire procurement lifecycle. 
MARA ensures that materials remain consistent entities regardless of operational context, supporting analytics that cut 
across plants, vendors, and purchasing documents. Its structure mirrors the SAP standard design, focusing on global, 
non-organizational attributes.

### Cryptic Name: Why “MARA”?
SAP uses the prefix **MA** to denote *Material*–related tables. The suffix **RA** originates from early R/2-era internal 
naming conventions, where different two-letter endings distinguished material master segments. Although historically 
inherited, “MARA” consistently refers to the general (cross-plant) material attributes and is one of the most widely 
referenced tables in SAP MM.

### Field Explanations

- **MATNR** (***Mat**erial **Nr**.* → Material Number)  
  The unique identifier of a material. It is the primary key of MARA and is referenced by nearly every procurement, 
inventory, and valuation table. In SAP, MATNR is typically 18 characters (numeric or alphanumeric), defining the 
universal identity of the material across all organizational views.

- **MTART** (***M**a**t**erial **Art** → Material Type)  
  Specifies the material type, a classification controlling system behavior such as which views are allowed, whether the 
material is purchased or produced, and which valuation rules apply. Material type is essential for data governance and 
business rules configuration.

- **MATKL** (***Mat**erial **Kl**asse → Material Group)  
  A broad grouping used for reporting, spend analysis, and procurement analytics. Material group helps categorize 
materials independent of vendor or plant, supporting aggregation and segmentation.

- **MEINS** (***Me**ss**ein**heit → Base Unit of Measure)  
  Defines the unit in which the material is primarily managed (e.g., EA, KG, M). It affects purchasing, stocking, and 
inventory valuation. All quantity conversions derive from this base unit.

## MARD – Storage Location Material Data

The `MARD` table defines material data at the level of plant and storage location, forming the operational backbone of 
inventory management in the nano-mm model. While MARA provides the global identity of a material, MARD specifies *where* 
that material physically resides and how it behaves within a specific logistical context. Each record links a material 
to a plant and storage location, enabling precise tracking of stock quantities, availability, and movement. In SAP MM, 
this table supports essential processes such as goods receipts, issues, transfers, cycle counting, and availability 
checks. It also integrates with procurement processes, since purchasing decisions often depend on current stock levels 
per location. In this project, `MARD` allows the simulation of multi-plant inventories, distributed warehouses, and 
localized stock behavior. It provides the granularity required for analytics such as stock aging, storage utilization, 
and plant-to-plant supply flows. Without MARD, no realistic procurement or logistics modeling could take place.

### Cryptic Name: Why “MARD”?
The prefix **MA** identifies material-related tables. The suffix **RD** originates from legacy R/2 naming conventions, 
where different two-letter endings were used to differentiate storage-location-level data from plant-level (e.g., MARD 
vs. MARC). Although historically inherited, “MARD” consistently refers to material master data maintained at *plant + 
storage location* granularity.

### Field Explanations

- **MATNR** (***MAT**erial **NR**.* → Material Number)  
  Identifies the material for this inventory record. It provides the connection back to MARA and ensures that stock is 
tracked consistently across logistics and procurement processes.

- **WERKS** (***W**ERK → Plant)  
  Specifies the plant in which the material is held. This establishes the organizational and logistical context for 
stock data and drives valuation, availability checks, and movement rules.

- **LGORT** (***LG**er**ORT** → Storage Location)  
  Defines the specific storage location within the plant. It introduces sub-plant granularity, reflecting warehouses, 
zones, shelves, or logical partitions where materials are stored.

- **LABST** (***L**ager**best**and → Unrestricted-use Stock)  
  Represents the quantity of valuated, unrestricted-use stock available at the storage location. This is the most 
operationally important stock category, as it is immediately available for consumption, sales, or further movement. 
LABST plays a direct role in procurement decisions and availability calculations.

## MBEW – Material Valuation Data

The `MBEW` table represents material valuation data and forms one of the most financially significant components of the 
nano-mm model. While MARA defines the general attributes of a material and MARD describes its physical distribution, 
MBEW captures the monetary dimension: how the material is valued within a specific valuation area. In this project, the 
valuation area (`BWKEY`) is mapped to the plant level, mirroring a common configuration in SAP systems where each plant 
maintains its own valuation data. MBEW is essential for determining standard price, inventory valuation, and cost-based 
procurement decisions. It directly influences financial postings created during goods movements, invoice verification, 
and stock adjustments. By modeling material valuation separately, the system supports scenarios such as plant-specific 
pricing, margin analysis, and simulated cost changes. MBEW provides the financial backbone required for integrating 
procurement operations with accounting principles and enables realistic analytics related to cost structures and 
material profitability.

### Cryptic Name: Why “MBEW”?
The prefix **MB** refers to *Material Bewirtschaftung* (material management/valuation) in SAP’s legacy terminology. The 
suffix **EW** comes from *EinWertung* (valuation). Combined, “MBEW” has historically denoted the material valuation 
segment of the material master, distinguishing it from general attributes (MARA) and storage data (MARD).

### Field Explanations

- **MATNR** (***MAT**erial **NR**.* → Material Number)  
  Identifies the material for which valuation data is maintained. Links directly to MARA and ensures that valuation 
logic applies consistently across processes.

- **BWKEY** (***B**e**w**ertungs**key** → Valuation Area)  
  Represents the valuation area, mapped to the plant level in this project. It determines where valuation data is valid 
and enables plant-specific cost structures. BWKEY is central to inventory valuation, cost calculations, and financial 
postings.

- **STPRS** (***ST**andard**PR**ei**S** → Standard Price)  
  The standard price of the material for the valuation area. Used in standard-costing environments to determine 
inventory value, cost of goods sold, and material variances.

- **PEINH** (***P**reis**einh**eit → Price Unit)  
  Defines the quantity unit to which the standard price refers (e.g., price per 1, 10, or 100 units). This ensures 
consistent price calculations and controls how valuation scales across material quantities.

## LFA1 – Vendor Master (General Data)

The `LFA1` table contains the general master data for vendors, representing information that is valid across all company 
codes and purchasing organizations. In the nano-mm model, LFA1 provides the foundational identity of each vendor, 
allowing the system to treat suppliers as consistent business partners across procurement scenarios. This table captures 
attributes that do not depend on financial or purchasing-specific relationships, making it essential for establishing 
the global profile of a vendor. Within real SAP systems, LFA1 participates in a multi-layered vendor master structure, 
where company-code-specific data (e.g., payment terms) and purchasing-specific data (e.g., order currency) are stored in 
separate tables. In our simplified design, LFA1 focuses exclusively on universal attributes such as vendor ID, name, and 
country. This supports key processes like purchase order creation, invoice processing, and spend analytics. LFA1 ensures 
that all downstream documents can consistently reference the same vendor entity regardless of the organizational 
context.

### Cryptic Name: Why “LFA1”?
The prefix **LF** comes from the German word *Lieferant* (vendor or supplier). The suffix **A1** was historically 
assigned to the general-data segment of the vendor master during SAP R/2 and early R/3 design. As a result, “LFA1” 
consistently refers to the global, cross-company-code portion of vendor information.

### Field Explanations

- **LIFNR** (***LIF**eranten**NR**.* → Vendor Number)  
  The unique identifier of the vendor. Used across procurement and financial processes to reference the supplier 
consistently in purchase orders, goods receipts, and invoices.

- **NAME1** (**Name** → Vendor Name)  
  The primary descriptive name of the vendor. Provides a human-readable label used in documents, UIs, and analytics. 
This field is informational and not used for control logic.

- **LAND1** (***LAND** → Country)  
  Specifies the vendor’s country. This attribute influences tax determination, import/export classification, and 
compliance checks, making it relevant to both procurement and financial processing.

## EKKO – Purchasing Document Header

The `EKKO` table represents the header segment of purchasing documents, forming the entry point of the procurement 
process in the nano-mm model. Each record corresponds to an entire purchase order and stores information that applies 
globally across all its item lines. This includes the company code responsible for the purchase, the vendor issuing the 
goods or services, the creation date of the document, and the currency in which the order is valued. In SAP’s 
architecture, EKKO structures the high-level commercial and organizational context, while item-level details such as 
materials, quantities, and delivery data reside in the associated EKPO table. In this project, `EKKO` enables realistic 
modeling of procurement lifecycles by capturing supplier relationships, financial ownership of orders, and temporal 
patterns of purchasing activity. It also supports analytics such as spend classification, vendor performance tracking, 
and multi-company procurement behavior. Without EKKO, no coherent purchasing document structure could be represented.

### Cryptic Name: Why “EKKO”?
The prefix **EK** derives from the German term *Einkauf* (purchasing). SAP uses **EK** consistently across all 
purchasing document tables. The suffix **KO** originates from *KOpf* (header) in German. Thus, “EKKO” literally means 
“Purchasing Header,” distinguishing it from EKPO, the purchasing document item table.

### Field Explanations

- **EBELN** (***E**inkaufs**BEL**eg**N**ummer → Purchasing Document Number)  
  The unique identifier of the purchase order. Serves as the key that links the header (EKKO) to all item-level records 
(EKPO).

- **BUKRS** (***BU**chungs**K**rei**S** → Company Code)  
  Specifies the legal entity responsible for the purchase. Determines financial ownership, currency defaults, and 
downstream accounting behavior.

- **LIFNR** (***LIF**eranten**NR**.* → Vendor Number)  
  Identifies the supplier from whom the goods or services are ordered. Links directly to LFA1 and is essential for 
vendor-specific reporting and invoice matching.

- **BEDAT** (***B**Estehungs**DAT**um → Purchasing Document Date)  
  The creation date of the purchase order. Used for spend analysis, reporting, period closing, and chronological 
tracking of procurement activity.

- **WAERS** (***W**äh**r**ung**S** → Currency)  
  Defines the currency of the purchase order. Governs valuation of items and directly impacts invoice verification and 
financial postings.

## EKPO – Purchasing Document Item

The `EKPO` table represents the item-level segment of purchasing documents and is one of the most important operational 
tables in the nano-mm model. While EKKO defines the header context of a purchase order, EKPO captures the concrete line 
items that specify which materials are being procured, in what quantities, for which plants, and at what prices. Each 
record corresponds to a single purchase order line, forming the link between organizational structure, material master 
data, and valuation logic. This table is central to the execution of procurement processes: it drives goods receipts, 
invoice verification, and commitment tracking. In analytics, EKPO provides the granular view required for spend 
analysis, vendor performance evaluation, and material-level purchasing patterns. Within this project, `EKPO` enables 
realistic modeling of multi-line purchase orders, plant-specific sourcing, and pricing structures, serving as a key 
bridge between master data tables and downstream logistics and financial flows.

### Cryptic Name: Why “EKPO”?
The prefix **EK** comes from the German word *Einkauf* (purchasing), used consistently for purchasing-related tables. 
The suffix **PO** originates from *POsition* (item or line). Together, “EKPO” means “Purchasing Document Item,” 
distinguishing it from EKKO, which stores the corresponding header data.

### Field Explanations

- **EBELN** (***E**inkaufs**BEL**eg**N**ummer → Purchasing Document Number)  
  Identifies the purchase order to which the item belongs. It links each line item back to its header in EKKO and is 
essential for grouping items into a single purchasing document.

- **EBELP** (***E**inkaufs**BEL**eg**P**osition → Item Number)  
  The sequential item number within a purchase order. It uniquely distinguishes one line item from another under the 
same purchasing document.

- **MATNR** (***MAT**erial **NR**.* → Material Number)  
  Specifies which material is being ordered on this item. It connects the line to the material master and enables 
material-level purchasing and inventory analysis.

- **WERKS** (***WERK** → Plant)  
  Indicates the plant for which the material is being procured. It determines where stock will be received and how 
valuation and logistics rules apply.

- **MENGE** (***MENGE** → Quantity)  
  The ordered quantity for this line item. It drives requirements for goods receipt, inventory updates, and subsequent 
invoice quantities.

- **MEINS** (***ME**ngen**EIN**heißt → Order Unit)  
  The unit of measure in which the ordered quantity is expressed (e.g., EA, KG, M). It defines how quantities are 
interpreted operationally.

- **NETPR** (***NET**to**PR**eis → Net Price)  
  The net price for the item per price unit, excluding taxes and certain surcharges. It is a key input to valuation and 
invoice verification.

- **PEINH** (***P**reis**EINH**eit → Price Unit)  
  Defines the quantity basis for the net price (e.g., price per 1, 10, or 100 units). It controls how the net price 
scales with the ordered quantity.

- **NETWR** (***NET**to**W**e**R**t → Net Item Value)  
  The total net value of the line item, derived from quantity, net price, and price unit. It is central to spend 
analysis and financial postings.

## EKBE – Purchasing Document History

The `EKBE` table stores the history of follow-on documents for purchase order items, linking each line in a purchase 
order to its subsequent goods receipts, invoice receipts, and other relevant events. While EKKO and EKPO describe the 
intended procurement (who orders what, for which plant, and at what price), EKBE captures what actually happens over 
time. Each record represents a concrete event against a purchase order item, such as a goods receipt or an invoice 
posting, including the posting date, quantities, and amounts in local currency. This makes EKBE essential for 
reconciling ordered quantities and values with received and invoiced ones. In the nano-mm model, `EKBE` enables 
realistic scenarios for three-way matching, partial deliveries, and delayed invoicing. It also provides the 
transactional backbone for analytics like GR/IR reconciliation, lead time measurement, and tracking the life cycle of a 
purchase order item from creation to final settlement.

### Cryptic Name: Why “EKBE”?

The prefix **EK** is derived from the German word *Einkauf* (purchasing) and is used consistently for purchasing 
document tables. The suffix **BE** comes from *BEleg* (document). Together, “EKBE” refers to purchasing document history 
records, connecting purchase order items to their related follow-on documents.

### Field Explanations

- **EBELN** (***E**inkaufs**BEL**eg**N**ummer → Purchasing Document Number)  
  Identifies the purchase order to which the history record belongs. It links each event back to the original purchasing 
document.

- **EBELP** (***E**inkaufs**BEL**eg**P**osition → Item Number)  
  Identifies the specific purchase order item. Together with EBELN, it uniquely anchors each history entry to a concrete 
line in EKPO.

- **VGABE** – Event Type  
  Encodes the type of follow-on event, such as goods receipt (`1`), invoice receipt (`2`), or other purchasing-related 
movements. It determines how the record should be interpreted in GR/IR and lifecycle analysis.

- **GJAHR** (***G**eschäfts**JAHR** → Fiscal Year)  
  Specifies the fiscal year of the follow-on document. This is crucial for period-based reporting, reconciliation, and 
auditability.

- **BELNR** (***BEL**eg**NR**.* → Document Number)  
  The number of the follow-on document (e.g., material document or accounting document). It links EKBE to the subsequent 
process layer in inventory or finance.

- **BUZEI** – Item in Follow-on Document  
  Identifies the line item within the follow-on document. Used together with BELNR to uniquely reference a specific 
posting line.

- **BUDAT** (***BU**chungs**DAT**um → Posting Date)  
  The posting date of the follow-on document. It is essential for period determination, reporting, and understanding 
when events actually affected stock and value.

- **MENGE** (***MENGE** → Quantity)  
  The quantity associated with the history event (e.g., received or invoiced quantity). It is used to reconcile ordered, 
delivered, and invoiced amounts at item level.

- **DMBTR** – Amount in Local Currency  
  The monetary amount of the history record in local currency. It supports financial reconciliation, GR/IR analysis, and 
cost tracking for each event.

## MKPF – Material Document Header

The `MKPF` table represents the header segment of material documents, which record physical inventory movements in the 
nano-mm model. While purchase orders describe intended procurement and EKBE captures follow-on history, MKPF documents 
the actual logistics events entering or leaving stock, such as goods receipts, goods issues, and transfer postings. Each 
material document consists of a header in MKPF and one or more item lines in MSEG, capturing the operational effect of 
movements on plant and storage location inventories. The header stores information that applies to all items within the 
document, including the posting date and the document’s fiscal year. By providing temporal context, MKPF enables 
chronological tracking of stock movements, supports reconciliation between purchasing and logistics, and forms the basis 
for inventory reporting. In this project, `MKPF` allows the simulation of physical stock operations and anchors the 
event-driven flow that connects procurement execution with inventory updates.

### Cryptic Name: Why “MKPF”?

The prefix **MK** originates from *MaterialKopf*, where *Kopf* means “header” in German. SAP uses **M** consistently for 
material-movement documents. The suffix **PF** is inherited from older SAP R/2 internal naming conventions that 
distinguished header segments from item segments (e.g., MKPF vs. MSEG). Thus, MKPF refers specifically to the material 
document header.

### Field Explanations

- **MBLNR** (***M**aterial**BL**att**NR**.* → Material Document Number)  
  The unique identifier of a material document. Groups all item lines belonging to the same logistical event. It is the 
central reference for linking stock movements and their effects on inventory.

- **MJAHR** (***M**aterial**J**ahr → Material Document Year)  
  Specifies the fiscal year of the material document. Essential for period-based reporting, reconciliation, and 
chronological navigation of stock movements.

- **BUDAT** (***BU**chungs**DAT**um → Posting Date)  
  The date on which the material document is posted. Determines the accounting period and operational timing of the 
stock movement, influencing availability, valuation, and GR/IR reconciliation.

## MSEG – Material Document Item

The `MSEG` table represents the item-level segment of material documents and captures the concrete logistics movements 
that affect inventory. While MKPF provides the document header and high-level posting context, MSEG holds the individual 
lines that specify which materials moved, in what quantities, to or from which plant and storage location, and under 
which movement type. Each record models a single stock-relevant event, such as a goods receipt from a purchase order, a 
goods issue to consumption, or an internal transfer between storage locations. This table therefore forms the 
operational heart of inventory flow in the nano-mm model. It connects material master data, organizational structure, 
and valuation by carrying both quantities and amounts in local currency. In analytics, `MSEG` enables detailed views of 
stock movements over time, movement-type distributions, and the impact of logistics events on inventory value. Without 
MSEG, inventory behavior would remain purely theoretical and disconnected from real process execution.

### Cryptic Name: Why “MSEG”?

The name “MSEG” combines **M** for material-related documents with **SEG**, short for *Segment*. In SAP terminology, 
MSEG has historically denoted the item or segment portion of a material document, as opposed to MKPF, which stores the 
header. Together, MKPF and MSEG form the complete representation of material documents.

### Field Explanations

- **MBLNR** (***M**aterial**BL**att**NR**.* → Material Document Number)  
  Identifies the material document to which the item belongs. Groups multiple MSEG lines under a single logistical event 
represented by MKPF.

- **MJAHR** (***M**aterial**JAHR** → Material Document Year)  
  The fiscal year associated with the material document. Used for period-based reporting, navigation, and 
reconciliation.

- **ZEILE** (***ZEIL**e → Line)  
  The line item number within the material document. Uniquely distinguishes individual movement lines under the same 
document number.

- **MATNR** (***MAT**erial **NR**.* → Material Number)  
  Identifies the material affected by the movement. Links the logistics event back to the material master.

- **WERKS** (***WERK** → Plant)  
  Specifies the plant in which the movement occurs. Determines organizational and logistical context for the stock 
change.

- **LGORT** (***L**ager**ORT** → Storage Location)  
  Defines the storage location within the plant that is impacted. Provides sub-plant granularity for inventory 
movements.

- **BWART** (***BEW**egungs**ART** → Movement Type)  
  Encodes the nature of the stock movement (e.g., goods receipt, goods issue, transfer). It controls how the movement is 
interpreted in inventory and accounting.

- **MENGE** (***MENGE** → Quantity)  
  The quantity moved in this line item. Drives stock level changes and is central to logistics analytics.

- **MEINS** (***ME**ss**EIN**heit → Unit of Measure)  
  The unit of measure in which the movement quantity is expressed (e.g., EA, KG, M). Ensures consistent interpretation 
of quantities.

- **DMBTR** – Amount in Local Currency  
  The monetary value of the movement in local currency. Supports valuation-related reporting and reconciliation.

- **WAERS** (***W**ä**r**ung**S** → Currency)  
  The currency key for the amount in this line item. Ensures correct monetary interpretation and alignment with 
financial postings.

## RBKP – Invoice Document Header

The `RBKP` table contains the header information for vendor invoices and is a key component of the Invoice Verification 
(LIV) process in the nano-mm model. While purchase orders and goods receipts describe the intention and physical flow of 
procurement, RBKP represents the financial realization of these transactions: the supplier’s invoice. Each record 
corresponds to one invoice document and stores global attributes such as the vendor, company code, invoice date, posting 
date, and currency. This header-level data defines the accounting context within which individual invoice items 
(represented in RSEG) are processed. RBKP is essential for matching invoices against purchase orders and goods receipts, 
performing price and quantity checks, and creating financial postings. In analytics, it supports spend reporting, vendor 
performance evaluation, GR/IR reconciliation, and period-end processes. Within this project, `RBKP` enables realistic 
simulation of invoice flows and bridges procurement operations with financial accounting through a structured document 
lifecycle.

### Cryptic Name: Why “RBKP”?

The prefix **RB** comes from the German term *RechnungsBeleg* (invoice document). The suffix **KP** derives from *Kopf* 
(header). Together, “RBKP” denotes the header portion of an invoice document in the LIV process, analogous to how MKPF 
represents the header of a material document.

### Field Explanations

- **BELNR** (***BEL**eg**NR**.* → Document Number)  
  The unique identifier of the invoice document. Serves as the anchor for linking invoice items (RSEG) to their invoice 
header.

- **GJAHR** (***G**eschäfts**JAHR** → Fiscal Year)  
  Specifies the fiscal year of the invoice document. Used for financial period assignment, reporting, and 
reconciliation.

- **BUKRS** (***BU**chungs**KR**eis → Company Code)  
  Indicates the legal entity responsible for processing and posting the invoice. Determines accounting rules and 
currency defaults.

- **LIFNR** (***LIF**eranten**NR**.* → Vendor Number)  
  Identifies the supplier who issued the invoice. Links directly to LFA1 and is central for vendor-level analytics.

- **BLDAT** (***BL**att**DAT**um → Invoice Document Date)  
  The date printed on the vendor’s invoice. Used for payment terms, invoice aging, and validation checks.

- **BUDAT** (***BU**chungs**DAT**um → Posting Date)  
  The date the invoice is posted into the system. Drives financial period determination and accounting alignment.

- **WAERS** (***W**äh**r**ung**S** → Currency)  
  The currency in which the invoice is valued. Governs subsequent valuation, payment processing, and analytics.

## RSEG – Invoice Document Item

The `RSEG` table stores the item-level details of vendor invoices, forming the granular component of the Invoice 
Verification (LIV) process in the nano-mm model. While RBKP represents the overall invoice header, RSEG captures each 
invoiced line and links it directly back to the corresponding purchase order item. This connection enables 3-way 
matching between purchase order quantity, goods receipt quantity, and invoiced quantity. Each record contains the 
invoiced material, quantity, unit of measure, and monetary amount, allowing the system to validate whether the invoice 
is correct, identify discrepancies, and determine whether additional actions such as blocking or variance posting are 
required. RSEG is central to financial reconciliation, since it provides the detailed basis for valuation checks and the 
creation of accounting postings. In analytics, it supports vendor performance tracking, invoice accuracy metrics, and 
procurement–finance alignment. Without RSEG, invoice processing would lack the detail needed for compliant and auditable 
procurement operations.

### Cryptic Name: Why “RSEG”?

The prefix **RS** originates from *RechnungsSegment*, meaning “invoice segment” or “invoice line.” The suffix **EG** is 
derived from older SAP R/2 naming conventions to denote item-level detail. Together, “RSEG” identifies the table that 
stores invoice item data, complementing RBKP, the invoice header table.

### Field Explanations

- **BELNR** (***BEL**eg**NR**.* → Document Number)  
  The invoice document number. Links each invoice item to its header in RBKP.

- **GJAHR** (***G**eschäfts**JAHR** → Fiscal Year)  
  Specifies the fiscal year of the invoice document. Necessary for period determination and reconciliation.

- **BUZEI** (***BU**chungs**ZEI**le → Line Item)  
  The line item number within the invoice document. Distinguishes one invoice item from another under the same invoice 
header.

- **EBELN** (***E**inkaufs**BEL**eg**N**ummer → PO Number)  
  Identifies the purchase order to which the invoice item relates. Enables linking invoice to procurement intention.

- **EBELP** (***E**inkaufs**BEL**eg**P**osition → PO Item)  
  The specific purchase order line that this invoice item refers to. Forms the backbone of 3-way matching.

- **MATNR** (***MAT**erial **NR**.* → Material Number)  
  Identifies the invoiced material. Ensures that quantities and values are reconciled at material level.

- **MENGE** (***MENGE** → Quantity)  
  The invoiced quantity for this line. Compared against ordered and received quantities during invoice verification.

- **MEINS** (***ME**ss**EIN**heit → Unit of Measure)  
  The unit in which the invoiced quantity is expressed. Must align with PO and GR units or undergo conversion.

- **WRBTR** (***W**e**R**t in **B**eleg**TR**äge → Amount in Document Currency)  
  The monetary amount of the invoice item. Used for financial postings, invoice variance checks, and spend analysis.
