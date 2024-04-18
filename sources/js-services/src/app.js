var jl = require('jsonld');
var fs = require('fs');
const express = require('express');



const app = express();



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






/* frame just request, or also response (in the exact same way?)?*/
app.post('/frame', async (req, res) => {
  
	const input_file_path = req.body.input_file_path;
	const input_file_name = req.body.input_file_name;
	const destination_dir_path = req.body.destination_dir_path; // converted/
	const dest = destination_dir_path + '/' + input_file_name + '.jsonld'

	var doc = await load_n3(input_file_path, false);
	var r = await do_frame(doc, frame);
	clean(r);
	
	JSON.dump(r, fs.createWriteStream(dest));
	
    res.json({result: dest});
})



app.post('/request_jsonld_to_rdf', async (req, res) => {
  
	const input_file_path = req.body.input_file_path;
	const input_file_name = req.body.input_file_name;
	const destination_dir_path = req.body.destination_dir_path; // converted/
	const dest = destination_dir_path + input_file_name + '.nq'
	
	var j = await JSON.parse(fs.readFileSync(input_file_path, {encoding: 'utf-8'}));
	j['@context'] = ctx;
	const rdf_string = await jl.toRDF(j,	{format: 'application/n-quads'});
    fs.writeFileSync(dest, rdf_string, {encoding: 'utf-8'});

    res.json({result: dest});
})


app.get('/health', async (req, res) => {
    res.json({result: 'ok'});
})



const port = 17790;

app.listen(port, () => {
    console.error(`Example app listening at http://localhost:${port}`)
});

