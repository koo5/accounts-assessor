var jl = require('jsonld');
var fs = require('fs');
var n3 = require('n3');
var path = require('path');

const express = require('express');



const app = express();
app.use(express.json());



const ctx = {
//	"@base": "https://rdf.lodgeit.net.au/v1/",

	"xsd": "http://www.w3.org/2001/XMLSchema#",
	"rdf": "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
	"rdfs": "http://www.w3.org/2000/01/rdf-schema#",
	"excel": "https://rdf.lodgeit.net.au/v1/excel#",

	"depr": "https://rdf.lodgeit.net.au/v1/calcs/depr#",
	"depr_ui": "https://rdf.lodgeit.net.au/v1/calcs/depr/ui#",
	"smsf": "https://rdf.lodgeit.net.au/v1/calcs/smsf#",
	"smsf_ui": "https://rdf.lodgeit.net.au/v1/calcs/smsf/ui#",
	"smsf_distribution": "https://rdf.lodgeit.net.au/v1/calcs/smsf/distribution#",
	"smsf_distribution_ui": "https://rdf.lodgeit.net.au/v1/calcs/smsf/distribution_ui#",

	"excel:optional":{"@type":"xsd:boolean"},
	"excel:cardinality":{"@type":"@id"},
	"excel:type":{"@type":"@id"},
	"excel:sheets":{"@type":"@id"},
	"excel:has_sheet":{"@type":"@id"},
	"excel:multiple_sheets_allowed":{"@type":"xsd:boolean"},
	"excel:is_horizontal":{"@type":"xsd:boolean"},

	"is_type_of": {"@reverse": "rdf:type2", "@container": "@set"},
	"is_range_of": {"@reverse": "rdfs:range"},

};



const frame = {
  "@context": ctx,

  //"@type":"excel:example_sheet_set",
  //"@type":"excel:sheet_set",
  //"@type":"excel:Request",
	"@id":"https://rdf.lodgeit.net.au/v1/excel_request#request",
	"rdf:value":
		{
			"@list": [
				{
					"@embed": "@always",
					"@omitDefault": true

				}
			]
		}

};




function n3lib_quad_to_jld(x)
{
	return {
		subject: n3lib_term_to_jld(x.subject),
		predicate: n3lib_term_to_jld(x.predicate),
		object: n3lib_term_to_jld(x.object),
		graph: n3lib_term_to_jld(x.graph)
	}
}

function n3lib_term_to_jld(x)
{
	const termType = x.termType;
	const value = x.value;
	switch (termType)
	{
		case 'NamedNode':
			return {termType, value}
		case 'BlankNode':
			return {termType, value: '_:' + value}
		case 'Literal':
			const r = {termType, value}
			if (x.language)
				r.language = x.language
			if (x.datatype)
				r.datatype = x.datatype
			return r
		case 'DefaultGraph':
			return {termType, value}
		default:
			throw Error('unknown termType: ' + termType)
	}
}



async function n3_file_jld_quads(fn)
{
	const store = new n3.Store();
	const parser = new n3.Parser(/*{format: 'N3'}*/);
	var n3_text = fs.readFileSync(fn, {encoding: 'utf-8'});
	const quads = await parser.parse(n3_text)
	const quads2 = quads.map(n3lib_quad_to_jld);
	return quads2;
}





async function do_add_type2_quads(quads)
{
	//hack around json-ld @reverse rdf:type problem by adding "rdf:type2" for each "rdf:type" quad.
	// i believe the problem was that i wanted things like this in the context:
	//"is_type_of": {"@reverse": "rdf:type2", "@container": "@set"},
	// but due to a peculiarity of the library, it wouldn't work with rdf:type

	const to_be_added = [];
	quads.forEach((q) =>
	{
		const p = q.predicate;
		if (p.termType == "NamedNode" && p.value == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
		{
			to_be_added.push({
				subject: q.subject,
				predicate: {termType: "NamedNode", value: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type2"},
				object: q.object,
				graph: q.graph
			})
		}
	})

	to_be_added.forEach((q) =>
		quads.push(q));
}




async function simplify(frame)
{
	let f = await cars_framed(source);
	let items = f['@graph'][0]['rdf:value']['@list'];
	items.forEach(i => {
		for (const [key, value] of Object.entries(i)) {
			let v = value['rdf:value'];
			if (v !== undefined)
				i[key] = v;
		}
	});
	return items;
}



async function do_frame(data, frame)
{
	const framed = await jl.frame(data, frame, {
		base: "http://ex.com/",
		processingMode: "json-ld-1.1",
		omitGraph: true,
		embed: '@once',
		ordered: true
	})
	return framed
}



function clean(data) {
	//console.log(data);
	var del = [];
	for (var key in data) {
		var value = data[key];
		//console.error(key);
		
		/*if (key === "excel:sheet_instance_has_sheet_type") {
			data[key] = value['@id'];
		}*/ // this wont translate back without this in the context: "ex:contains": {"@type": "@id"}

		if (
			(key === "rdf:value" && value === null) ||
			key === "excel:col" || 
			key === "excel:row" || 
			key === "excel:title" || 
			key === "excel:position" || 
			key === "excel:has_sheet_name" || 
			key === "excel:template" ||
			key === "excel:sheet_type"
			) {
			//console.log('deleting ' + key + '...');
			del.push(key);
		}
		else if ((typeof value) === 'object') {
			//console.log(value);
			if (value != null)
				clean(value);
		}
	}
	for (var k of del) {
		console.error('deleting ' + k + '...');
		delete data[k];
	}
}



async function load_n3(fn, add_type2_quads=true)
{
	const quads = await n3_file_jld_quads(fn);
	if (add_type2_quads)
		do_add_type2_quads(quads);
	const data = await jl.fromRDF(quads);
	return data;
}



/* frame just request, or also response (in the exact same way?)?*/
app.post('/frame', async (req, res) => {

	const body = req.body;
	const input_file_path = body.input_file_path;
	const input_file_name = path.basename(input_file_path);
	const destination_dir_path = body.destination_dir_path; // converted/
	const dest = destination_dir_path + '/' + input_file_name + '.jsonld'
	const frame_root_uri = body.frame_root_uri;
	if (frame_root_uri) {
		//deep copy frame
		var frame2 = JSON.parse(JSON.stringify(frame));
		frame2['@id'] = frame_root_uri;
	}
	else
	    var frame2 = frame;

    console.error('frame', input_file_path, dest, frame2);

	var doc = await load_n3(input_file_path, false);
	var r = await do_frame(doc, frame2);
	clean(r);
	
	fs.createWriteStream(dest).write(JSON.stringify(r, null, 4)); 
	
	res.json({output_file_path: dest});
})



app.post('/request_jsonld_to_rdf', async (req, res) => {

	const input_file_path = req.body.input_file_path;
	const input_file_name = path.basename(input_file_path);
	const destination_dir_path = req.body.destination_dir_path; // converted/
	const dest = destination_dir_path + '/' + input_file_name + '.nq'
	
	var j = await JSON.parse(fs.readFileSync(input_file_path, {encoding: 'utf-8'}));
	j['@context'] = ctx;
	const rdf_string = await jl.toRDF(j, {format: 'application/n-quads'});
	fs.writeFileSync(dest, rdf_string, {encoding: 'utf-8'});

	res.json({output_file_path: dest});
})


app.get('/health', async (req, res) => {
	res.json({result: 'ok'});
})



const port = 17790;

app.listen(port, () => {
	console.error(`Example app listening at http://localhost:${port}`)
});

