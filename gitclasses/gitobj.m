classdef gitobj
    properties
        analysisID
        acquisition_software = ''
        admit_delay = 0
        aliquot = ''
        analysis_type = ''
        analyist_name = ''
        collection_version = ''
        comment= ''
        commit=''
        conditionals
        data_reduction_software=''
        detectors= {}
        environmental= environmentalobj
        experiment_queue_name=''
        extraction=''
        identifier=''
        increment
        instrument_name=''
        intensity_scalar='1.0'
        irradiation=''
        irradiation_level=''
        irradiation_position = 0
        isotopes = isotopesobj
        laboratory=''
        mass_spectrometer=''
        material=''
        measurement=''
        post_equilibration=''
        post_measurement=''
        principal_investigator=''
        project=''
        queue_conditionals_name=''
        repository_identifier=''
        sample=''
        source=sourceobj
        spec_sha=''
        timestamp=''
        tripped_conditional
        username = ''
        uuid =''
        whiff_result
        
    end
end
% 