package inject

import (
	"github.com/bersennaidoo/microdataservice/infrastructure/repositories/mysqldb"
	"github.com/bersennaidoo/microdataservice/transport/rpc/stats/wireclient"
	"github.com/google/wire"
)

var Inject = wire.NewSet(
	mysqldb.Connect,
	Sonyflake,
	wireclient.Inject,
)
