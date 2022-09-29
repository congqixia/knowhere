
%module swigknowhere;

#pragma SWIG nowarn=321
#pragma SWIG nowarn=403
#pragma SWIG nowarn=325
#pragma SWIG nowarn=389
#pragma SWIG nowarn=341
#pragma SWIG nowarn=512
#pragma SWIG nowarn=362

%include <stdint.i>
typedef uint64_t size_t;
#define __restrict

%ignore knowhere::IndexFactory;
%ignore knowhere::IndexNode;
%ignore knowhere::Index;
%ignore knowhere::DataSet;
%ignore knowhere::expected;

%{
#include <stdint.h>

#include <memory>
#ifdef SWIGPYTHON
#undef popcount64
#define SWIG_FILE_WITH_INIT
#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION
#include <numpy/arrayobject.h>
#endif
//#include <knowhere/expected.h>
#include <knowhere/knowhere.h>
using namespace knowhere;
%}

%{
#define SWIG_FILE_WITH_INIT
%}
%include "numpy.i"
%init %{
import_array();
%}



%include <std_string.i>
%include <std_pair.i>
%include <std_map.i>
%include <std_shared_ptr.i>
%include <exception.i>
%include <knowhere/expected.h>
%include <knowhere/dataset.h>
%include <knowhere/binaryset.h>
%template(DataSetPtr) std::shared_ptr<knowhere::DataSet>;
%template(BinarySetPtr) std::shared_ptr<knowhere::BinarySet>;
%apply (float* IN_ARRAY2, int DIM1, int DIM2) {(float* xb, int nb, int dim)}
%apply (int* IN_ARRAY2, int DIM1, int DIM2) {(int* xb, int nb, int dim)}
%apply (uint8_t *IN_ARRAY1, int DIM1) {(uint8_t *block, int size)}
%apply (int *IN_ARRAY1, int DIM1) {(int *lims, int len)}
%apply (int *IN_ARRAY1, int DIM1) {(int *ids, int len)}
%apply (float *IN_ARRAY1, int DIM1) {(float *dis, int len)}
%apply (float* INPLACE_ARRAY2, int DIM1, int DIM2){(float *dis,int nq_1,int k_1)}
%apply (int *INPLACE_ARRAY2, int DIM1, int DIM2){(int *ids,int nq_2,int k_2)}


%inline %{


class IndexWrap {
 public:
    IndexWrap(const std::string& name) {
        idx = IndexFactory::Instance().Create(name);
    }

    Error
    Build(DataSetPtr dataset, const std::string& json) {
        return idx.Build(*dataset, knowhere::Json::parse(json));
    }

    Error
    Train(DataSetPtr dataset, const std::string& json) {
        return idx.Train(*dataset, knowhere::Json::parse(json));
    }

    Error
    Add(DataSetPtr dataset, const std::string& json) {
        return idx.Add(*dataset, knowhere::Json::parse(json));
    }

    DataSetPtr
    Search(DataSetPtr dataset, const std::string& json) {
        auto res = idx.Search(*dataset, knowhere::Json::parse(json), nullptr);
        if (res.has_value())
            return res.value();
        return nullptr;
    }

    DataSetPtr
    GetVectorByIds(DataSetPtr dataset, const std::string& json) {
        auto res = idx.GetVectorByIds(*dataset, knowhere::Json::parse(json));
        if (res.has_value())
            return res.value();
        return nullptr;
    }

    Error
    Serialization(BinarySetPtr binset) {
        return idx.Serialization(*binset);
    }
    Error
    Deserialization(BinarySetPtr binset) {
        return idx.Deserialization(*binset);
    }

    int64_t
    Dims() {
        return idx.Dims();
    }

    int64_t
    Size() {
        return idx.Size();
    }

    int64_t
    Count() {
        return idx.Count();
    }

    std::string
    Type() {
        return idx.Type();
    }

 private:
    Index<IndexNode> idx;
};

DataSetPtr
Array2DataSet(float* xb, int nb, int dim) {
    auto ds = std::make_shared<DataSet>();
    ds->SetRows(nb);
    ds->SetDim(dim);
    ds->SetTensor(xb);
    return ds;
};

void
DataSet2Array(DataSetPtr result, float* dis, int nq_1, int k_1, int* ids, int nq_2, int k_2) {
    auto ids_ = result->GetIds();
    auto dist_ = result->GetDistance();
    assert(nq_1 == nq_2);
    assert(k_1 == k_2);
    for (int i = 0; i < nq_1; i++) {
        for (int j = 0; j < k_1; ++j) {
            *(ids + i * k_1 + j) = *((int64_t*)(ids_) + i * k_1 + j);
            *(dis + i * k_1 + j) = *((float*)(dist_) + i * k_1 + j);
        }
    }
}


%}